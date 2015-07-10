require 'exfiltrate/gopher'
require 'exfiltrate/event_format'

class Exfiltrate::TestConnection
  attr_accessor :users, :channel, :callback, :messages, :bandwidth, :to_send

  def initialize
    self.users    = %w[Gopher1 Gopher2 Gopher3 Glena]
    self.channel  = 'test-channel'
    self.messages = []
    self.to_send  = []
    self.callback = lambda { |*event| to_send << event }
  end

  def list
    messages << [:list]
  end

  def send_file(recipient, filename)
    messages << [:send, recipient, filename]
  end

  def close
    messages << [:close]
  end

  def on_data(&callback)
    self.callback = callback
    users.each { |u| callback.call :join, u, channel }
    callback.call :starting
    to_send.each { |e| callback.call *e }
    self
  end

  def emit(type, *args)
    callback.call type, *args
    self
  end

  def emit_channel(channel)
    self.channel = channel
    self
  end

  def emit_join(*names)
    self.users = names
    self
  end

  def emit_bandwidth(bw)
    callback.call :bandwidth, bw
    self
  end

  def emit_files(files)
    files.each { |file| callback.call :file, file }
    self
  end

  def emit_receive_file(data)
    callback.call :receive_file, 'file4', 41, 42
    self
  end

  def emit_finished
    callback.call :finished
    self
  end
end

