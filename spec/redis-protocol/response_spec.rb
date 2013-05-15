require_relative '../spec_helper'

describe RedisProtocol::Response do
  it 'should be parse response' do
    result = RedisProtocol::Response.new "*3\r\n$3\r\nset\r\n$4\r\ntest\r\n$5\r\nhello\r\n"
    result.result[0].should eql 'set'
    result.result[1].should eql 'test'
    result.result[2].should eql 'hello'
  end
end