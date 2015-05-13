%%%-------------------------------------------------------------------
%%% @author Alexey Shilenkov
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Mar 2015 2:12 AM
%%%-------------------------------------------------------------------
-module(pool).
-author("Alexey Shilenkov").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-include("../archive.hrl").

-define(SERVER, ?MODULE).
-define(RECEIVE_POOL, receive_pool).


-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
  wpool_pool:create_table(),
  case wpool:start_pool(?RECEIVE_POOL, [{workers, ?RECEIVE_WORKERS_NUM}, {worker, {coder_minion, []}}]) of
    {ok, PID} -> lager:info("~p is started with PID = ~p & Workers ~p~n", [?RECEIVE_POOL, PID, ?RECEIVE_WORKERS_NUM]);
    _ -> lager:error("Error starting ~s pool~n", [?RECEIVE_POOL])
  end,
  {ok, #state{}}.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  wpool:stop(?RECEIVE_POOL),
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
