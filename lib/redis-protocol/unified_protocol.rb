class RedisProtocol::UnifiedProtocol
  DELIMITER="\r\n"
  class << self
    def parse(data)
      processed, index = 0, data.index(DELIMITER)
      index ||= data.length
      result = case data[processed]
                 when '*'
                   parse_multi_chunked data
                 when '$'
                   parse_chunked data
                 when '+'
                   parse_status data
                 when '-'
                   parse_error data
                 when ':'
                   parse_integer data
               end
    end

    def parse_multi_chunked(data)
      index = data.index DELIMITER
      count = data[1...index].to_i
      result = []
      start = index + DELIMITER.length
      1.upto(count) do |_|
        chunk, length = parse_chunked data, start
        start = length + DELIMITER.length
        result += chunk
      end

      result
    end

    def parse_chunked(data, start=0)
      index = data.index DELIMITER, start
      length = data[(start+1)...index].to_i
      return nil if length == -1
      result = [data[index+DELIMITER.length, length]]

      start == 0 ? result : [result, index+DELIMITER.length + length]
    end

    def parse_status(data)
      [true, data[1..-1]]
    end

    def parse_error(data)
      [false, data[1..-1]]
    end

    def parse_integer(data)
      [data[1..-1].to_i]
    end
  end
end