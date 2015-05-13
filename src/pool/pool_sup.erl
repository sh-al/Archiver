%%%-------------------------------------------------------------------
%%% @author Alexey Shilenkov
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Mar 2015 2:08 AM
%%%-------------------------------------------------------------------
-module(pool_sup).
-author("Alexey Shilenkov").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).
%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
    MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
    [ChildSpec :: supervisor:child_spec()]
  }} |
  ignore |
  {error, Reason :: term()}).

init([]) ->
  lager:info("Pool Supervisor Init ~n", []),
  {ok, {{one_for_one, 5, 10}, [
    ?CHILD(pool, worker)
  ]}}.

%% init([]) ->
%%   RestartStrategy = one_for_one,
%%   MaxRestarts = 1000,
%%   MaxSecondsBetweenRestarts = 3600,
%%
%%   SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
%%
%%   Restart = permanent,
%%   Shutdown = 2000,
%%   Type = worker,
%%
%%   AChild = {'AName', {'AModule', start_link, []},
%%     Restart, Shutdown, Type, ['AModule']},
%%
%%   {ok, {SupFlags, [AChild]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
