require_relative '../spec_helper'

describe RedisProtocol::Request do
  it 'initialize with data' do
    RedisProtocol::Request.new 'ping'
  end

  it 'should get raw data as original' do
    request = RedisProtocol::Request.new 'ping'
    request.raw_data.should eql 'ping'
  end

  it 'should parse inline command' do
    request = RedisProtocol::Request.new 'ping'
    request.components[0].should eql 'ping'
    request.component_count.should be 1
  end

  it 'should parse inline command with parameter' do
    request = RedisProtocol::Request.new 'keys *'
    request.components[0].should eql 'keys'
    request.component_count.should be 2
  end

  it 'should parse inline command with multi whitespaces' do
    request = RedisProtocol::Request.new 'keys    *'
    request.components[0].should eql 'keys'
    request.component_count.should be 2
  end

  it 'should parse standard command' do
    request = RedisProtocol::Request.new "*1\r\n$4\r\nping"
    request.components[0].should eql 'ping'
    request.component_count.should be 1
  end

  it 'should parse standard command with parameter' do
    request = RedisProtocol::Request.new "*2\r\n$4\r\nkeys\r\n$1\r\n*"
    request.components[0].should eql 'keys'
    request.component_count.should be 2
  end

  it 'should parse standard command with multiple parameters' do
    request = RedisProtocol::Request.new "*3\r\n$3\r\nset\r\n$4\r\ntest\r\n$5\r\nhello"
    request.components[0].should eql 'set'
    request.component_count.should be 3
  end

  it 'should parse standard command containing delimiter' do
    request = RedisProtocol::Request.new "*3\r\n$3\r\nset\r\n$4\r\ntest\r\n$12\r\nhello\r\nworld"
    request.components[2].should eql "hello\r\nworld"
    request.component_count.should be 3
  end
end
