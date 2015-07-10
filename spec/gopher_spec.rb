require 'exfiltrate/gopher'

# RSpec.describe Exfiltrate::Gopher do
RSpec.describe 'abc' do
  def gopher_for(conn)
    Exfiltrate::Gopher.new(conn)
  end
  # /look
  # /msg Gopher1 hello
  # /send Gopher2 GCHQ.ppt
  # /list
  class Exfiltrate::TestConnection
    def emit_join(*names)
      @users = names
    end
    #   --> | Gopher1 has joined #hello, waiting for teammates...
    #   --> | Gopher2 has joined #hello, waiting for teammates...
    #   --> | Gopher3 has joined #hello, waiting for teammates...
    #  * -- | Everyone has arrived, mission starting...
    #  * -- | Ask for /help to get familiar around here
  end

  def new_connection
    Exfiltrate::TestConnection.new
  end

  describe 'connecting' do
    it 'considers itself is the first gopher that it sees join' do
      conn   = new_connection.emit_join('Gopher1', 'Gopher2')
      gopher = Exfiltrate::Gopher.connect conn
      expect(gopher.name).to eq 'Gopher1'

      conn   = new_connection.emit_join('Gopher2', 'Gopher1')
      gopher = Exfiltrate::Gopher.connect conn
      expect(gopher.name).to eq 'Gopher2'
    end

    it 'lists out its files' do
      conn   = new_connection
      gopher = Exfiltrate::Gopher.connect conn
      expect(conn.messages '/list').to eq [:list]
    end
  end

  # describe 'looking around the room' do
  #   it 'tracks the names of the participants'
  #   it 'records who it is after messaging another user'
  # end

  describe 'receiving info' do
    it 'tracks its bandwidth' do
      conn   = new_connection
      gopher = gopher_for conn
      expect(gopher.bandwidth).to eq nil
      conn.emit_bandwidth(123)
      expect(gopher.bandwidth).to eq 123
      expect(conn.messages).to be_empty
    end

    it 'tracks the files it sees, their size, and their value' do
      conn   = new_connection
      gopher = gopher_for conn
      expect(gopher.file_list).to eq []

      conn.emit_files [
        [              '641A.ppt', 3041, 66],
        ['BoundlessInformant.doc', 2695, 36],
      ]

      expect(gopher.file_list).to [
        [              '641A.ppt', 3041, 66],
        ['BoundlessInformant.doc', 2695, 36],
      ]

      expect(conn.messages).to be_empty
    end
  end

  describe 'sending and receiving files' do
    let :conn do
      new_connection
        .emit_bandwidth(1000)
        .emit_files([['file1', 11, 12], ['file2', 21, 22], ['file3', 31, 32]])
    end

    let(:gopher) { gopher_for conn }

    it 'removes a file from its index, after sending it' do
      gopher.send_file 'file2.doc', to: 'Gopher2'
      expect(gopher.filenames).to eq ['file1', 'file3']
      expect(conn.messages).to eq [[:send, 'Gopher2', 'BoundlessInformant']]
    end

    it 'records no cost or score when sending files to other gophers' do
      expect(gopher.bandwidth).to eq 1000
      expect(gopher.score).to eq 0
      gopher.send_file 'file2.doc', to: 'Gopher2'
      expect(gopher.bandwidth).to eq 1000
      expect(gopher.score).to eq 0
    end

    it 'deducts the filesize as a bandwidth cost and adds the secrecy value ot its score, when sending files to Glenda' do
      expect(gopher.bandwidth).to eq 1000
      expect(gopher.score).to eq 0
      gopher.send_file 'file2.doc', to: 'Glenda'
      expect(gopher.bandwidth).to eq 1000-21
      expect(gopher.score).to eq 22
    end

    it 'adds a file to its index, after receiving it' do
      conn.emit_receive_file ['file4', 41, 42]
      expect(gopher.filenames).to eq %w[file1 file2 file3 file4]
    end
  end

  # possibly something about queuing up moves asynchronously?
end
