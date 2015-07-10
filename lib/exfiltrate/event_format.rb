require 'exfiltrate'

class Exfiltrate
  module EventFormat
    extend self

    def from_line(line)
      type, message = line.split(/\s*\|\s*/, 2)
      case type.delete('-').strip
      when 'list'
        from_list line, message
      when 'send'
        from_send line, message
      when '>'
        name, _, _, hash_channel = message.split
        channel = hash_channel[1..-1]
        [:join, name, channel]
      when '*'
        [:starting]
      when 'look'
        [:noop]
      when 'help'
        [:noop]
      when 'msg'
        [:noop]
      when 'fail'
        [:finished]
      when 'err'
        raise YouFuckedUp, message
      else
        raise UnhandledEvent, line
      end
    end

    def self.from_list(line, message)
      case message
      when /^Remaining Bandwidth:\s*(\d+)\s*/
        [:bandwidth, $1.to_i]
      when /^\s*name\s*size\ssecrecy\svalue$/i
        [:noop]
      when /^\s*(\S+)\s*(\d*)kb\s*(\d*)$/i
        [:file, [$1, $2.to_i, $3.to_i]]
      else
        raise UnhandledEvent, line
      end
    end

    # send -- | Sent File: GCHQ.ppt to Gopher2
    # send -- | Received File: 641A.doc(496) from Gopher2
    def self.from_send(line, message)
      case message
      when /sent\s*file:\s*(\S+)\s*to\s*(.*)$/i
        filename  = $1
        recipient = $2
        [:noop]
      when /received\s*file:\s*(\S+)\s*from\s*(.*)$/i
        filename  = $1
        recipient = $2
        [:noop]
      else raise UnhandledEvent, line
      end
    end
  end
end
