require_relative 'unified_protocol'

class RedisProtocol::Response
  attr_reader :result

  def initialize(data)
    @raw_data = data
    @result = RedisProtocol::UnifiedProtocol.parse data
  end
end
