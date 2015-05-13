-module(webserver_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
  lager:info("Webservices Supervisor StartLink ~n", []),
  application:start(crypto)
  ,  application:start(cowlib)
  ,  application:start(ranch)
  ,  application:start(cowboy)
  ,   supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
  lager:info("Webservices Supervisor Init ~n", []),
  {ok, {{one_for_one, 5, 10}, [
    ?CHILD(web_server, supervisor)
  ]}}.

