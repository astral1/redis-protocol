class RedisProtocol::Request
  attr_reader :raw_data, :type, :component_count, :components

  def initialize(data)
    @raw_data = data
    @type, @components, @component_count, @current = nil, [], 0, ''
    @next_length = 0
    parse
  end

  private

  def parse
    @raw_data.chars.each do |c|
      @type ||= c.eql?('*') ? :standard : :inline

      send(@type, c)
    end

    complete_token
    @component_count += @components.count if @type == :inline
  end
=begin
    Inline Parser
=end
  def inline(char)
    c = char.strip

    if c.empty? and not @current.empty?
      complete_token
    else
      @current += c
    end
  end

=begin
    Standard Parser
=end

  def standard(char)
    @token_type ||= detect_token_type char
    @doubt_str = ''

    send(@token_type, char)
  end

  def args_counts(char)
    return if char.eql? '*'

    tokenize char do
      @component_count = @current.to_i
      clean_context
    end
  end

  def length(char)
    return if char.eql? '$'

    tokenize char do
      @next_length = @current.to_i
      clean_context
    end
  end

  def payload(char)
    return if char.eql? '$'

    @next_length = 0 if @current.length == @next_length

    tokenize char do
      @next_length = 0
      complete_token
    end
  end

  def tokenize(char, &block)
    reach_delimiter = consume_delimiter(char)

    if reach_delimiter
      if @doubt_str.empty?
        block.call
      end
      return
    end

    @current += char
  end

=begin
    Common Utilities
=end

  def complete_token
    @components << @current
    clean_context
  end

  def clean_context
    @current = ''
    @token_type = nil
  end

  def consume_delimiter(char)
    return false if @next_length != 0

    if @doubt and char.eql? "\n"
      @doubt_str = ''
      @doubt = false
      return true
    end

    if not @doubt and char.eql? "\r"
      @doubt_str = "\r"
      @doubt = true
      return true
    end

    @doubt = false
    @current += @doubt_str unless @doubt_str.empty?
    @doubt_str = ''
    return false
  end

  def detect_token_type(char)
    case char
      when '*'
        :args_counts
      when '$'
        :length
      else
        :payload
    end
  end
end
