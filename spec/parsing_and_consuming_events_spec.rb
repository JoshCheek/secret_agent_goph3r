require 'spec_helper'

RSpec.describe Exfiltrate::EventFormat do
  let(:server) { Exfiltrate::TestConnection.new }
  let(:gopher) { Exfiltrate::Gopher.new server }

  def from_line(line)
    Exfiltrate::EventFormat.from_line line
  end

  it "can process each of the events we know are going to come up, and the gopher doesn't blow up on them" do
    lines = <<-LINES.lines
       --> | Gopher1 has joined #hello, waiting for teammates...
       --> | Gopher2 has joined #hello, waiting for teammates...
       --> | Gopher3 has joined #hello, waiting for teammates...
      * -- | Everyone has arrived, mission starting...
      * -- | Ask for /help to get familiar around here
   help -- |  Usage:
   help -- |
   help -- |  	 /[cmd] [arguments]
   help -- |
   help -- |  Available commands:
   help -- |
   help -- |  	/msg [to] [text]         send message to coworker
   help -- |  	/list                    look at files you have access to
   help -- |  	/send [to] [filename]    move file to coworker
   help -- |  	/look                    show coworkers
   look -- | You look around at your co-workers' nametags:
   look -- |
   look -- | 	Gopher1
   look -- | 	Gopher2
   look -- | 	Gopher3
   look -- | 	Glenda
    msg -- | *msg from Gopher1: hello
    msg -- | *msg to Gopher1: hello
   list -- | Remaining Bandwidth: 14636 KB
   list -- |                       Name   Size Secrecy Value
   list -- |                   641A.ppt 3041KB            66
   list -- |     BoundlessInformant.doc 2695KB            36
   list -- |     BoundlessInformant.ppt 2836KB            95
   list -- |             EgoGiraffe.doc 2711KB            32
   list -- |             EgoGiraffe.ppt 1985KB            71
   list -- |                   GCHQ.doc 2217KB            77
   list -- |                   GCHQ.ppt  376KB            35
   list -- |                  PRISM.doc 2869KB            70
   list -- |                  PRISM.ppt  344KB            51
   list -- | RadicalPornEnthusiasts.doc 1278KB            44
   list -- | RadicalPornEnthusiasts.ppt 2042KB            44
   list -- |                 SIGINT.doc  812KB            81
   list -- |                 SIGINT.ppt 2069KB            19
   list -- |              TorStinks.doc 1631KB            18
   list -- |              TorStinks.ppt 2367KB            38
    send -- | Sent File: GCHQ.ppt to Gopher2
    send -- | Received File: 641A.doc(496) from Gopher2
   list -- | Remaining Bandwidth: 14636 KB
   list -- |                       Name   Size Secrecy Value
   list -- |                   641A.doc  496KB            18
   list -- |                   641A.ppt 3041KB            66
   list -- |     BoundlessInformant.doc 2695KB            36
   list -- |     BoundlessInformant.ppt 2836KB            95
   list -- |             EgoGiraffe.doc 2711KB            32
   list -- |             EgoGiraffe.ppt 1985KB            71
   list -- |                   GCHQ.doc 2217KB            77
   list -- |                  PRISM.doc 2869KB            70
   list -- |                  PRISM.ppt  344KB            51
   list -- | RadicalPornEnthusiasts.doc 1278KB            44
   list -- | RadicalPornEnthusiasts.ppt 2042KB            44
   list -- |                 SIGINT.doc  812KB            81
   list -- |                 SIGINT.ppt 2069KB            19
   list -- |              TorStinks.doc 1631KB            18
   list -- |              TorStinks.ppt 2367KB            38
   send -- | Sent File: 641A.doc to Glenda
   list -- | Remaining Bandwidth: 14140 KB
   list -- |                       Name   Size Secrecy Value
   list -- |                   641A.ppt 3041KB            66
   list -- |     BoundlessInformant.doc 2695KB            36
   list -- |     BoundlessInformant.ppt 2836KB            95
   list -- |             EgoGiraffe.doc 2711KB            32
   list -- |             EgoGiraffe.ppt 1985KB            71
   list -- |                   GCHQ.doc 2217KB            77
   list -- |                  PRISM.doc 2869KB            70
   list -- |                  PRISM.ppt  344KB            51
   list -- | RadicalPornEnthusiasts.doc 1278KB            44
   list -- | RadicalPornEnthusiasts.ppt 2042KB            44
   list -- |                 SIGINT.doc  812KB            81
   list -- |                 SIGINT.ppt 2069KB            19
   list -- |              TorStinks.doc 1631KB            18
   list -- |              TorStinks.ppt 2367KB            38
      fail | You wake up bleary eyed and alone in a concrete box. Your head has a
      fail | lump on the side. It seems corporate security noticed you didn't belong,
      fail | you should have acted faster. You wonder if you will ever see your
      fail | burrow again
    LINES

    lines.each do |line|
      result = from_line line
      expect(result.first).to be_a_kind_of Symbol
      server.emit(*result)
    end

    # didn't blow up, that's good ;P  Here's an assertion anyway
    expect(gopher.bandwidth).to eq 14140
    expect(gopher.file_list).to include ['SIGINT.doc', 812, 81]
  end

  it 'raises an exception on errors' do
    line = "err -- |  Invalid command try '/help' to see valid commands"

    expect { from_line line } .to raise_error \
      Exfiltrate::YouFuckedUp,
      "Invalid command try '/help' to see valid commands"
  end

  it 'raises an exception on events it doesn\'t understand' do
    expect { from_line "no pipe" } .to raise_error \
      Exfiltrate::UnhandledEvent, "no pipe"

    expect { from_line "whatever | something" } .to raise_error \
      Exfiltrate::UnhandledEvent, "whatever | something"

    expect { from_line "list -- | lol wat" } .to raise_error \
      Exfiltrate::UnhandledEvent, "list -- | lol wat"

    expect { from_line "send -- | lol wat" } .to raise_error \
      Exfiltrate::UnhandledEvent, "send -- | lol wat"
  end
end
