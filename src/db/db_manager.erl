%%%-------------------------------------------------------------------
%%% @author Alexey Shilenkov
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Feb 2015 11:07 PM
%%%-------------------------------------------------------------------
-module(db_manager).
-author("Alexey Shilenkov").

-behaviour(gen_server).

-include("../archive.hrl").

%% API
-export([start_link/0, get_number_of_recs/0, pop/0, pop/1, drop_all_tables/0, append_queue/2]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-define(DB, db).
-define(DB_File, "db.sqlite3").
-define(TABLE_NAME, queue).


-define(COUNT, "SELECT COUNT(*) FROM queue").
-define(ITERATE, "SELECT id, name FROM queue").
-define(APPEND, "INSERT INTO queue (name, path) VALUES (?, ?)").
-define(WRITE_LOCK, "BEGIN IMMEDIATE").
-define(POP_LEFT_GET, "SELECT id, name, path FROM queue ORDER BY id LIMIT 1").
-define(POP_RIGHT_GET, "SELECT id, name, path FROM queue ORDER BY id DESC LIMIT 1").
-define(POP_DEL, "DELETE FROM queue WHERE id = ?").
-define(PEEK, "SELECT item FROM queue ORDER BY id LIMIT 1").
-define(SELECT_ALL, "select * FROM queue").

% sqlite3:sql_exec(ct, "INSERT INTO user1 (id, name) VALUES (?, ?)", [{1, 1}, {2, "john"}]),
-record(state, {q_length}).


%% %% @equiv gen_server:call(Process, Call, Timeout)
%% -spec call(wpool:name() | pid(), term(), timeout()) -> term().
%% call(Process, Call, Timeout) -> gen_server:call(Process, Call, Timeout).
%%
%% %% @equiv gen_server:cast(Process, Cast)
%% -spec cast(wpool:name() | pid(), term()) -> ok.
%% cast(Process, Cast) -> gen_server:cast(Process, Cast).

%%%===================================================================
%%% API
%%%===================================================================

-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

get_number_of_recs() ->
  {status, Pid, {module, Mod}, [PDict, SysState, Parent, Dbg, [Header, Data, {data, [{StateSmth, State}]}]]} = sys:get_status(?MODULE, 700),
  {state, Number} = State,
  Number.


%external function

%call
get_count() ->
  [{Ret}] = rows(sqlite3:sql_exec(?DB, ?COUNT)),
  Ret.
%gen_server:call(?MODULE, count).

iterate() ->
  gen_server:call(?MODULE, iter).

pop() ->
  %gen_server:call(?MODULE, {get_all_devices, []}).
  gen_server:call(?MODULE, {pop, right}).
pop(Atom) when Atom == left ->
  gen_server:call(?MODULE, {pop, left}).

peek() ->
  gen_server:call(?MODULE, peek).

append_queue(Name, Path) ->
  gen_server:cast(?MODULE, {append_q, Name, Path}).


drop_if_exist(Db, Table) ->
  gen_server:call(?MODULE, drop_exist, [Db, Table]).

drop_all() ->
  gen_server:call(?MODULE, drop_all).


create_table() ->
  case lists:member(?TABLE_NAME, sqlite3:list_tables(?DB)) of
    true -> ok;
    false -> sqlite3:create_table(?DB, ?TABLE_NAME,
      [
        {
          id, integer, [
          {primary_key, [asc, autoincrement]}]
        },
        {name, text},
        {path, text}
      ]),
      lager:info("table queue created")
  end.


%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).

init([wipe]) ->
  sqlite3:open(?DB, [{file, ?DB_File}]),
  drop_all_tables(),
  create_table();
init([]) ->
  sqlite3:open(?DB, [{file, ?DB_File}]),
  create_table(),
  select(),
  {ok, #state{q_length = get_count()}}.

%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).

%% handle_call({count, []}, _From, _State) ->
%%   [{Ret}] = rows(sqlite3:sql_exec(?DB, ?COUNT))
%%   , lager:debug("Queue count: ~p~n", [Ret])
%%   , Ret;
handle_call({iterate, []}, _From, _State) ->
  sqlite3:sql_exec(?DB, ?ITERATE);

handle_call({peek, []}, _From, _State) ->
  rows(sqlite3:sql_exec(?DB, ?PEEK));

handle_call({pop, Dir}, From, State) ->
  lager:debug("POP from ~p~n", [From]),
  case Dir of
    left -> Query = ?POP_LEFT_GET;
    _ -> Query = ?POP_RIGHT_GET
  end,
  %sqlite3:sql_exec(?DB,?WRITE_LOCK), %lock db
  case rows(sqlite3:sql_exec(?DB, Query)) of
    [{ID, Name, FName}] ->
      %lager:debug("popleft rows ID ~p FName ~p~n", [ID, FName]),
      sqlite3:sql_exec(?DB, ?POP_DEL, [ID]),
      Res = [Name, FName];
    _ -> lager:error("no rows in database"), ok,
      Res = []
  end,
%%   C=get_count(),
  {reply, Res, State#state{q_length = get_count()}};
handle_call({drop_exist, [Db, Table]}, _From, _state) ->
  drop_table_if_exists(Db, Table);

handle_call({drop_all}, _From, _state) ->
  drop_all_tables();

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%%--------------------------------------------------------------------

-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast({append_q, FileName, Path}, State) ->
  Res = sqlite3:sql_exec(?DB, ?APPEND, [FileName, Path]),
  lager:info("added to queue ~p~n", [Res]),
  {noreply, State#state{q_length = get_count()}};

handle_cast(_Request, State) ->
  lager:error("Unknown cast in db_manager"),
  {noreply, State}.

%%--------------------------------------------------------------------

-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------

-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  sqlite3:close(db),
  ok.

%%--------------------------------------------------------------------

-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

drop_table_if_exists(Db, Table) ->
  case lists:member(Table, sqlite3:list_tables(Db)) of
    true -> sqlite3:drop_table(Db, Table);
    false -> ok
  end.

drop_all_tables() ->
  Tables = sqlite3:list_tables(?DB),
  [sqlite3:drop_table(?DB, Table) || Table <- Tables],
  Tables.



rows(SqlExecReply) ->
  case SqlExecReply of
    [{columns, _Columns}, {rows, Rows}] -> Rows;
    {error, Code, Reason} -> {error, Code, Reason}
  end.


select() ->
  Res = rows(sqlite3:sql_exec(?DB, ?SELECT_ALL)),
  V = [X || {X, _, _F} <- Res],
  lager:debug("SQL Query: ~p~n ", [V]).

get_demo(Count) when Count > 0 ->
  %io_lib:format()
  Str1 = lists:concat([?TMP_PATH, Count]),
  Str2 = lists:concat([?FS_PATH, Count]),
  sqlite3:write(?DB, ?TABLE_NAME, [{name, Str1}, {path, Str2}]),
  %erlang:append(Str1, Str2),
  get_demo(Count - 1);
get_demo(_C) ->
  lager:info("demo data written").