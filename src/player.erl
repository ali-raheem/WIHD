-module(player).
-export([register_with_linker/1]).

%% @doc Await for a game name from the client and use it to register with Linker
register_with_linker(Socket) ->
    receive
	{tcp, Socket, Lobby} ->
	    whereis(linker) ! {looking, Lobby, self()},
	    wait_for_partner(Socket)
	after 1 -> register_with_linker(Socket)
    end,
    register_with_linker(Socket).

%% @doc Wait for linker to pair you with an opponent
wait_for_partner(Socket) ->
    receive
	{connect, Opponent} ->
	    link(Opponent),
	    relay(Socket, Opponent)
    end,
    wait_for_partner(Socket).

%% @doc Simple HTTP relay
%% Pass moves from your client to opponent.
relay(User, Opponent) ->
    receive
	{tcp, User, Move} ->
	    Opponent ! {self(), Move},
	    relay(User, Opponent);
	{Opponent, Move} -> 
	    case gen_tcp:send(User, Move) of
		ok -> relay(User, Opponent);
		_ -> exit(noproc)
	     end
%    after 600000 -> exit(noproc)
    end,
    relay(User, Opponent).
