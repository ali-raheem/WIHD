%% @author Ali Raheem <ali.raheem@gmail.com>
%% @copyright 2018 Ali Raheem
%% @doc An online multiplayer sever for War in Hex
%% Find this project on github [https://github.com/wolfmankurd/WIHD/]
%% Code for the client is here [https://github.com/wolfmankurd/war_in_hex]
%% War in Hex is a free game similar to the Hive abstract strategy game.

-module(wihd).
-export([start/0, start/1]).

%% @doc Start a WIHD server
%% Takes an optional Port argument defaults to 1664.
%% A good year for gaming ;/
%% @end
start() ->
    start(1664).
start(Port) ->
    supervisor(Port).

%% @doc Supervisor process to maintain server
%% Starts and restarts the Linker process and TCP server
%% @end
supervisor(Port) ->
    process_flag(trap_exit, true),
    Supervisor = spawn_link(fun() ->
				    {ok, Listen} = gen_tcp:listen(Port, [{active, true}]),
				    Linker = spawn_link(fun () -> linker() end),
				    register(linker, Linker),
				    Acceptor = spawn(fun () -> acceptor(Listen) end),
				    receive
					{'EXIT', _, shutdown} ->
					    exit(noproc);
					{'EXIT', _, normal} ->
					    exit(noproc);
					{'EXIT', _, _} ->
					    supervisor(Port)
				    end
			    end),
    {ok, Supervisor}.

%% @doc Basic client matching process
%% Maintain a proplist of game_names and waiting clients.
%% Add client to wait list or pair with a partner according to game name.
%% @end
linker() ->
    linker([]).
linker(L) ->
    receive
	{looking, Tag, User} ->
	    case proplists:get_value(Tag, L) of
		undefined ->
		    linker([{Tag, User}|L]);
		Partner ->
		    User ! {connect, Partner},
		    Partner ! {connect, User},
		    linker(proplists:delete(Tag, L))
	    end
    end,
    linker(L).

%% @doc Accept connections from TCP listener
acceptor(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    spawn(fun() ->
		  acceptor(ListenSocket)
	  end),
    register_with_linker(Socket).

%% @doc Await for a game name from the client and use it to register with Linker
register_with_linker(Socket) ->
    receive
	{tcp, Socket, Msg} ->
	    whereis(linker) ! {looking, Msg, self()},
	    wait_for_partner(Socket);
	_ -> register_with_linker(Socket)
    end.

%% @doc Wait for linker to pair you with an opponent
wait_for_partner(Socket) ->
    receive
	{connect, Opponent} ->
	    link(Opponent),
	    relay(Socket, Opponent);
	_ -> wait_for_partner(Socket)
    end.

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
	     end;
	_ -> relay(User, Opponent)
%% Time out after 10 minutes
	after 600000 -> exit(noproc)
    end.
