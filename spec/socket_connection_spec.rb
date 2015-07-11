require 'exfiltrate/socket_connection'


RSpec.describe Exfiltrate::SocketConnection do
  before { pending 'Don\'t reallyhave time to implement the rest of this.' }
  it 'connects to the channel on initialization' do
    Exfiltrate::SocketConnection.new(socket, "hello")
    assert_written socket, "hello"
  end

  it 'lists the files' do
    refute_written socket, "/list"
    connection.list
    assert_written socket, "/list"
  end

  it 'sends a file to a recipient' do
    refute_written socket, "/send"
    connection.send_file "Gopher2", "GCHQ.ppt"
    assert_written socket, "/send Gopher2 GCHQ.ppt"
  end

  it 'closes the socket' do
    expect(socket).to_not be_closed
    connection.close
    expect(socket).to be_closed
  end

  context 'when told to read' do
    it 'calls the callback with the formatted input' do
      socket.with_content "list -- | Remaining Bandwidth: 123 KB"
      seen = []
      connection.on_data { |result| seen << result }
      expect(seen).to be_empty
      connection.read
      expect(seen).to [[:bandwidth, 123]]
    end

    it 'blows up if the callback hasn\'t been set' do
      socket.with_content "list -- | Remaining Bandwidth: 123 KB"
      expect { connection.read }.to raise_error YouFuckedUp, /callback/
    end
  end
end
