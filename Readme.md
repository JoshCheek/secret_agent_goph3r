Secret Agent Goph3r
===================

The Gophercon is in town, they gave their attendees this challenge.

```
On a seemingly average day in Denver, CO

The Mission:

Can your team of Goph3rs exfiltrate data from a target agency?

  * netcat to this address to find out:

    gophercon2015.coreos.com : 4001

  * choose your room to get started...

Winners: visit the CoreOS booth to claim your prize
```


Useful info
-----------

* You are trying to send as much data to Glenda as you can
* There is a timeout of something or other
* There is a bandwidth limit
* Transferring between Gophers costs no bandwidth
* Listing files costs no bandwidth


Example
-------

I nc in, then do the same in two other terminals.
It asks for a "channel", I go with "hello".
I look at the values of the files with "/list"
Eventually I time out.

```
$ nc gophercon2015.coreos.com 4001
A monolithic building appears before you. You have arrived at the office. Try not to act nervous.
Log in to your team's assigned collaboration channel:
hello

      --> | Gopher1 has joined #hello, waiting for teammates...
      --> | Gopher2 has joined #hello, waiting for teammates...
      --> | Gopher3 has joined #hello, waiting for teammates...
     * -- | Everyone has arrived, mission starting...
     * -- | Ask for /help to get familiar around here

/help
   help -- |  Usage:
   help -- |
   help -- |     /[cmd] [arguments]
   help -- |
   help -- |  Available commands:
   help -- |
   help -- |    /msg [to] [text]         send message to coworker
   help -- |    /list                    look at files you have access to
   help -- |    /send [to] [filename]    move file to coworker
   help -- |    /look                    show coworkers

/list
   list -- | Remaining Bandwidth: 40141 KB
   list -- |                       Name   Size Secrecy Value
   list -- |                   641A.ppt  585KB            72
   list -- |     BoundlessInformant.doc 2328KB            56
   list -- |     BoundlessInformant.ppt 2499KB            56
   list -- |             EgoGiraffe.doc 1356KB            93
   list -- |             EgoGiraffe.ppt 1418KB            50
   list -- |                   GCHQ.doc 2683KB            78
   list -- |                   GCHQ.ppt 2235KB            94
   list -- |                  PRISM.doc 2143KB            79
   list -- |                  PRISM.ppt 2600KB            41
   list -- | RadicalPornEnthusiasts.doc 2474KB            77
   list -- | RadicalPornEnthusiasts.ppt  688KB            12
   list -- |                 SIGINT.doc 2305KB            88
   list -- |                 SIGINT.ppt  949KB            54
   list -- |              TorStinks.doc 3112KB            72
   list -- |              TorStinks.ppt  269KB            96

fail | You wake up bleary eyed and alone in a concrete box. Your head has a
fail | lump on the side. It seems corporate security noticed you didn't belong,
fail | you should have acted faster. You wonder if you will ever see your
fail | burrow again
```


Useful notes
------------

Start a TCP socket server

```sh
$ ruby -r socket -e '
  client = TCPServer.new(8889).accept
  client.puts "Your HTTP headers:", ""
  until "\r\n" == (line = client.gets)
    client.puts line
  end
  client.close
'
```

Connect to a server

```sh
$ ruby -r socket -e '
  socket = TCPSocket.new("localhost", 8889)
  $stdout.puts socket.gets
  socket.puts $stdin.gets
  $stdout.puts socket.gets
  socket.close
'
```

