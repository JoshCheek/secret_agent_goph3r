require 'socket'

class Exfiltrate
  class SocketConnection
    attr_accessor :socket, :channel, :to_send, :callback

    def initialize(socket, channel)
      self.channel  = channel
      self.socket   = ::TCPSocket.new socket
      self.callback = Proc.new { raise "No callback!" }
    end

    def list
      [:list]
    end

    def send_file(recipient, filename)
      [:send, recipient, filename]
    end

    def close
      socket.close
    end

    def on_data(&callback)
      self.callback = callback
      callback.call :starting
      self
    end
  end
end
