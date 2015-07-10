class Exfiltrate
  # /look
  # /msg Gopher1 hello
  # /send Gopher2 GCHQ.ppt
  # /list
  class Gopher
    def self.connect(server)
      new(server).tap(&:connect)
    end

    attr_accessor :server, :name, :channel, :bandwidth, :file_list, :score

    def initialize(server)
      self.score     = 0
      self.server    = server
      self.bandwidth = -1
      self.file_list = []
      server.on_data { |event, *args| consume event, args }
    end

    def list
      server.list
    end

    def connect
      server.list
    end

    def filenames
      file_list.map(&:first)
    end

    def send_file(filename, to:)
      removed, self.file_list = file_list.partition { |entry| entry.first == filename }
      if to == 'Glenda'
        removed.each do |fn, size, value|
          self.bandwidth -= size
          self.score += value
        end
      end
      server.send_file to, filename
    end

    def consume(event_type, args)
      case event_type
      when :file
        self.file_list << args.first
      when :join
        self.name    ||= args.first
        self.channel ||= args.last
      when :bandwidth
        self.bandwidth = args.first
      when :receive_file
        self.file_list << args
      when :starting
        # noop
      else
        raise "Unconsumed event: #{[event_type, *args].inspect}"
      end
    end
  end
end
