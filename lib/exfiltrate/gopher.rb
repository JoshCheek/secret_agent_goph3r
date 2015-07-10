class Exfiltrate
  class Gopher

    attr_accessor :server

    def initialize(server)
      self.server = server
    end

    def list
      server.list
    end
  end
end
