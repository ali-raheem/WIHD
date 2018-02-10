# WIHD v 0.1.1

[War in Hex](https://github.com/wolfmankurd/war_in_hex) daemon is a Online multipler server written in Erlang.

Great performance and uptime even on a Raspberry Pi 2.

Under GPLv3

### Running

I recommend running it in screen with the shell open but most people will probably just want to run it with noshell.

```
$ erl -noshell -s wihd start
```

### Usage

To connect to the server make sure the server port is accessible (1664 by default) and connect with the War in Hex client like so

```
$ python main.py -n SERVER_IP:SERVER_PORT -g GAME_NAME
```

To start a lobby or connect to one called GAME_NAME.

You can ommit the -g flag and GAME_NAME to connect to the "Any" lobby.

### Specification

A TCP connection is made to the server and then the client sends the GAME_NAME (which is sent as a quoted string) this is stored by the server. If there is no already existing client connected with that GAME_NAME a lobby is created.

If there is an already existing lobby then a relay connection is made between the sockets.

### Changelog

* 2018-02-02 - v0.1.0
- First working version