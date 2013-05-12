class RedisProtocol::StaticRequest
  attr_reader :raw_data, :type, :components, :component_count
  OP_DELIMITER = "\r\n"

  def initialize(data)
    @raw_data = data
    parse_request
  end

  def parse_request
    @type = check_request_type

    send @type
  end

  def self.recognize(data)
    (check_request_type == :inline) ? data.split[0] : data.split(OP_DELIMITER)[2]
  end

  def check_request_type
    (@raw_data.start_with? '*') ? :standard : :inline
  end

  def standard
    components = []
    data = @raw_data.dup
    operand_length, payload = operand_length_for data.split(OP_DELIMITER)
    1.upto(operand_length).each do |_|
      data, payload = unpack_payload(payload)
      components << data
    end
    @component_count = components.count
    @components = components
  end

  def operand_length_for(data)
    operand_length, payload = next_token data
    raise "invalid packet : #{operand_length}" unless operand_length.start_with? '*'
    operand_length = operand_length[1..-1].to_i

    [operand_length, payload]
  end

  def unpack_payload(payload)
    field_length, payload = next_token payload
    raise "invalid length format : #{field_length}" unless field_length.start_with? '$'
    field_length = field_length[1..-1].to_i
    next_token payload, field_length
  end

  def inline
    @components = @raw_data.split
    @component_count = @components.count
    @components
  end

  def next_token(data, length = 0)
    if data[0].length == length || length == 0
      [data[0], data[1..-1]]
    else
      multiline_token(data, length)
    end
  end

  def multiline_token(data, length)
    val, index = '', 0
    data.each do |token|
      val.empty? ? val = token : val += "\r\n#{token}"
      index += 1

      break if val.length == length
    end
    [val, data[index..-1]]
  end

  private :next_token, :standard, :inline, :operand_length_for, :unpack_payload, :multiline_token
end
