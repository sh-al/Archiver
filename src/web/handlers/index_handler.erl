-module(index_handler).
-behaviour(cowboy_http_handler).

%% Cowboy_http_handler callbacks
-export([
  init/3,
  handle/2,
  terminate/3
]).

-include("../../archive.hrl").
-include("../../helpers/helpers.hrl").



init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->
  {Method, Req2} = cowboy_req:method(Req),
  lager:debug("handling request Req ~p~n", [Req]),
  case Method of
    ?POST ->
      lager:debug("POST request"),
      Body = ?POST_RESP,
      {ok, Req3} = cowboy_req:reply(200, [], Body, Req2),
      {ok, Req3, State};
    ?GET ->
      lager:debug("GET request"),
      Body = ?GET_RESP,
      {ok, Req3} = cowboy_req:reply(200, [], Body, Req2),
      {ok, Req3, State};
    ?PUT ->
      lager:debug("PUT request"),
      Body = ?PUT_RESP,
%%======================================================================
      %%TODO add your own header parcing
      {_, Tmp, _} = cowboy_req:parse_header(<<"content-name">>, Req2),
      [FileName, Dom] = re:split(Tmp, ",", [{return, binary}]),
      [Node, Domain] = re:split(Dom, "@", [{return, binary}]),

      try %NOT ALLWAYS MATHCES!!!
        {_, File, _} = cowboy_req:body(Req2),
        save_file(FileName, Domain, Node, File)
      catch
        throw:Term -> Term;
        exit:Reason -> {exit, Reason}, lager:error("Exit in index_haldler line 47: ~s~n", [Reason]);
        error:Reason -> {error, {Reason, erlang:get_stacktrace()}}
      end,

%% %%======================================================================
      {ok, Req3} = cowboy_req:reply(200, [], Body, Req2),
      {ok, Req3, State};
    _ ->
      Body = ?DEFAULT_RESP,
      {ok, Req3} = cowboy_req:reply(200, [], Body, Req2),
      {ok, Req3, State}
  end.



save_file(FileName, Domain, Node, File) ->
  %TmpPath =io_lib:format("~s~s", [?DEFAULT_FSTMP,FileName]),
  file:write_file(io_lib:format("~s~s", [?DEFAULT_FSTMP, FileName]), File),
  Path =io_lib:format("~s~s~s~s~s",[?USER_FS_ROOT, ?toList(Domain), "/", ?toList(Node), "/"]),
  lager:debug("saving file path= ~p dest ~p~n",[FileName, Path]),
  db_manager:append_queue(FileName, lists:flatten(Path)),
  ok.

terminate(_Reason, _Req, _State) ->
  ok.