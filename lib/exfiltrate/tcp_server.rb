require 'socket'

class Exfiltrate
  class TcpServer
    def self.connect(url, port, channel)
      new(url, port).connect(channel)
    end

    attr_accessor :url, :port, :socket

    def initialize(url, port)
      self.url    = url
      self.port   = port
      self.socket = ::TCPSocket.new url, port
    end

    def help
    end

    def list
    end

    def send(user, filename)
    end
  end
end
