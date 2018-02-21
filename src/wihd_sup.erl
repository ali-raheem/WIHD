%%%-------------------------------------------------------------------
%% @doc wihd top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(wihd_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    ServerSpec = #{id => server,
		   start => {server, start_link, []},
		   restart => permanent,
		   shutdown => brutal_kill,
		   type => worker},
    LinkerSpec = #{id => linkerlobby,
		   start => {linker, start_link, []},
		   restart => permanent,
		   shutdown => brutal_kill,
		   type => worker},
    Children = [ServerSpec, LinkerSpec],
    {ok, { {one_for_all, 0, 1}, Children} }.

%%====================================================================
%% Internal functions
%%====================================================================
