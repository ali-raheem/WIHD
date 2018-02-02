# WIHD

[War in Hex](https://github.com/wolfmankurd/war_in_hex) daemon is a Online multipler server written in Erlang.

Great performance and uptime even on a Raspberry Pi 2.

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

