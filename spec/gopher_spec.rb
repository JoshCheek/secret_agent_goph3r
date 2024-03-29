require 'spec_helper'

RSpec.describe Exfiltrate::Gopher do
  def gopher_for(conn)
    Exfiltrate::Gopher.new(conn)
  end

  def new_connection
    Exfiltrate::TestConnection.new
  end

  describe 'connecting' do
    it 'considers itself is the first gopher that it sees join' do
      conn   = new_connection.emit_channel("channel1")
      gopher = Exfiltrate::Gopher.connect conn
      expect(gopher.channel).to eq 'channel1'

      conn   = new_connection.emit_channel("channel2")
      gopher = Exfiltrate::Gopher.connect conn
      expect(gopher.channel).to eq 'channel2'
    end

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
      expect(conn.messages).to include [:list]
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
      expect(gopher.bandwidth).to eq -1
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

      expect(gopher.file_list).to eq [
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
      gopher.send_file 'file2', to: 'Gopher2'
      expect(gopher.filenames).to eq ['file1', 'file3']
      expect(conn.messages).to eq [[:send, 'Gopher2', 'file2']]
    end

    it 'records no cost or score when sending files to other gophers' do
      expect(gopher.bandwidth).to eq 1000
      expect(gopher.score).to eq 0
      gopher.send_file 'file2', to: 'Gopher2'
      expect(gopher.bandwidth).to eq 1000
      expect(gopher.score).to eq 0
    end

    it 'deducts the filesize as a bandwidth cost and adds the secrecy value ot its score, when sending files to Glenda' do
      expect(gopher.bandwidth).to eq 1000
      expect(gopher.score).to eq 0
      gopher.send_file 'file2', to: 'Glenda'
      expect(gopher.bandwidth).to eq 1000-21
      expect(gopher.score).to eq 22
    end

    it 'adds a file to its index, after receiving it' do
      conn.emit_receive_file ['file4', 41, 42]
      expect(gopher.filenames).to eq %w[file1 file2 file3 file4]
    end
  end

  it 'closes the connection when finished' do
    conn = new_connection.emit_finished
    gopher = gopher_for conn
    expect(conn.messages).to eq [[:close]]
  end

  it 'blows up if it receives an unknown event' do
    conn = new_connection.emit(:wat)
    expect { gopher_for conn }
      .to raise_error Exfiltrate::UnhandledEvent, /wat/
  end

  # possibly something about queuing up moves asynchronously?
end
