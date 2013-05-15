require_relative 'unified_protocol'

class RedisProtocol::Response
  attr_reader :result, :raw_data

  def <<(value)
    @result += value.result
    unless value.result.empty?
      start = @raw_data.index('*') + 1
      finish = @raw_data.index(RedisProtocol::UnifiedProtocol::DELIMITER)
      @raw_data[start...finish] = @result.length.to_s

      @raw_data += value.raw_data[(value.raw_data.index(RedisProtocol::UnifiedProtocol::DELIMITER) + RedisProtocol::UnifiedProtocol::DELIMITER.length)..-1]
    end
  end

  def initialize(data)
    @raw_data = data
    @raw_data += RedisProtocol::UnifiedProtocol::DELIMITER unless @raw_data.end_with? RedisProtocol::UnifiedProtocol::DELIMITER
    @result = RedisProtocol::UnifiedProtocol.parse @raw_data
  end
end
