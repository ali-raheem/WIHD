-module(server).
-export([start_link/0]).


start_link() ->
    Port = 1664,
    {ok, Listen} = gen_tcp:listen(Port, [{active, true}]),
    acceptor(Listen).

%% @doc Accept connections from TCP listener
acceptor(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
 %   spawn(player, register_with_linker, [Socket]),
 %   acceptor(ListenSocket).
    spawn(server, acceptor, [ListenSocket]),
    player:register_with_linker(Socket).


