-module(linker).
-export([start_link/0]).

%% @doc Start Linker process
%% The Linker will maintain a list of open Lobbies and link up players with Lobbies
%% or start a new Lobby for it.
start_link() ->
    register(linker, self()),
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
