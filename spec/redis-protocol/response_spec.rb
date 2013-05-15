require_relative '../spec_helper'

describe RedisProtocol::Response do
  it 'should be parse response' do
    result = RedisProtocol::Response.new "*3\r\n$3\r\nset\r\n$4\r\ntest\r\n$5\r\nhello\r\n"
    result.result[0].should eql 'set'
    result.result[1].should eql 'test'
    result.result[2].should eql 'hello'
  end

  it 'should be parse aggregated response' do
    result = RedisProtocol::Response.new "*3\r\n$3\r\nset\r\n$4\r\ntest\r\n$5\r\nhello\r\n"
    additional = RedisProtocol::Response.new "*2\r\n$5\r\nworld\r\n$6\r\nturtle\r\n"
    result << additional
    result.result[0].should eql 'set'
    result.result[1].should eql 'test'
    result.result[2].should eql 'hello'
    result.result[3].should eql 'world'
    result.result[4].should eql 'turtle'
    result.raw_data.should eql "*5\r\n$3\r\nset\r\n$4\r\ntest\r\n$5\r\nhello\r\n$5\r\nworld\r\n$6\r\nturtle\r\n"
  end
end