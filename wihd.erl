-module(wihd).
-export([start/0, start/1]).

start() ->
    start(1664).
start(Port) ->
    supervisor(Port).

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

linker() ->
    linker([]).
linker(L) ->
%% Maintain a proplist of game_names and waiting clients.
%% Add client to wait list or pair with a partner according to game name.
    receive
	{looking, Tag, User} ->
	    case proplists:get_value(Tag, L) of
		undefined ->
		    linker([{Tag, User}|L]);
		Partner ->
		    User ! {connect, Partner},
		    Partner ! {connect, User},
		    linker(proplists:delete(tag, L))
	    end
    end,
    linker(L).

acceptor(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    spawn(fun() ->
		  register_with_linker(Socket),
	  end),
    acceptor(ListenSocket).

register_with_linker(Socket) ->
    receive
	{tcp, Socket, Msg} ->
	    whereis(linker) ! {looking, Msg, self()},
	    wait_for_partner(Socket);
	_ -> register_with_linker(Socket)
    end.

wait_for_partner(Socket) ->
%% Send Linker any game name, wait to be paired by Linker.
    receive
	{connect, Opponent} ->
	    link(Opponent),
	    relay(Socket, Opponent);
	_ -> wait_for_partner(Socket)
    end.

relay(User, Opponent) ->
%% Relay info between User over TCP and Opponent over PM.
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
