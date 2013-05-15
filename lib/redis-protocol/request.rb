require_relative 'unified_protocol'

class RedisProtocol::Request
  attr_reader :raw_data, :type, :components

  def initialize(data)
    @raw_data = data
    @type, @components= nil, []
    @next_length = 0
    parse
  end

  def component_count
    @components.length
  end

  private

  def parse
    @type ||= @raw_data[0].eql?('*') ? :standard : :inline

    @components = send(@type)
  end
=begin
    Inline Parser
=end
  def inline
    @raw_data.split
  end

=begin
    Standard Parser
=end

  def standard
    RedisProtocol::UnifiedProtocol.parse @raw_data
  end
end
