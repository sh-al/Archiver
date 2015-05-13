%%%-------------------------------------------------------------------
%%% @author Alexey Shilenkov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Jun 2014 12:49 AM
%%%-------------------------------------------------------------------
-module(image_handler).

-author("Alexey Shilenkov").

-behaviour(cowboy_http_handler).

%% API
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
  lager:debug("handling request IMAGE"),
  %lager:debug("index_handler"),
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
      {_, Tmp, _} = cowboy_req:parse_header(<<"content-name">>, Req2),
      [FileName, Dom] = re:split(Tmp, ",", [{return, binary}]),
      [Node, Domain] = re:split(Dom, "@", [{return, binary}]),

      try
        {_, File, _} = cowboy_req:body(Req2),

        save_image(FileName, Domain, Node, File)
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


save_image(FileName, Domain, Node, File) ->
  Cmd= io_lib:format("mkdir -p ~s~s/~s/", [?DEFAULT_IMG,Domain ,?USERD(Node)]),
  os:cmd(Cmd),
  Path=io_lib:format("~s~s/~s/~s", [?DEFAULT_IMG,Domain ,?USERD(Node), FileName]),
  file:write_file(Path, File).


terminate(_Reason, _Req, _State) ->
  ok.