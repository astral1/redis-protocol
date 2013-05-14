require_relative '../spec_helper'

describe RedisProtocol::UnifiedProtocol do
  it 'should parse a redis unified protocol based message' do
    result = RedisProtocol::UnifiedProtocol.parse "$4\r\nping"
    result[0].should eql 'ping'
  end

  it 'should parse multi-chunked format' do
    result = RedisProtocol::UnifiedProtocol.parse "*1\r\n$4\r\nping"
    result[0].should eql 'ping'
    result = RedisProtocol::UnifiedProtocol.parse "*2\r\n$4\r\nkeys\r\n$1\r\n*\r\n"
    result[0].should eql 'keys'
    result[1].should eql '*'
  end

  it 'should parse status ok' do
    result = RedisProtocol::UnifiedProtocol.parse '+ok'
    result[0].should be true
    result[1].should eql 'ok'
  end

  it 'should parse error with message' do
    result = RedisProtocol::UnifiedProtocol.parse "-ERR unknown command 'foobar'"
    result[0].should be false
    result[1].should eql "ERR unknown command 'foobar'"
  end

  it 'should parse integer only return' do
    result = RedisProtocol::UnifiedProtocol.parse ":1000\r\n"
    result[0].should be 1000
    RedisProtocol::UnifiedProtocol.parse(':-30')[0].should be -30
  end
end
