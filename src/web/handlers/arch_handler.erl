%%%-------------------------------------------------------------------
%%% @author Alexey Shilenkov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Feb 2014 11:00 PM
%%%-------------------------------------------------------------------
-module(arch_handler).
-author("Alexey Shilenkov").

-behaviour(cowboy_http_handler).
-include("../../archive.hrl").
-include_lib("kernel/include/file.hrl").


%% Cowboy_http_handler callbacks
-export([
  init/3,
  handle/2,
  terminate/3
]).


init({tcp, http}, Req, _Opts) ->

  {ok, Req, undefined_state}.

handle(Req, State) ->
  {Method, Req2} = cowboy_req:method(Req),
  case Method of
    ?GET->
      Body =  <<"<h1>This is a response for Get</h1>">>,
      {[{_,Code}],_}= cowboy_req:qs_vals(Req),
      lager:debug("Var ~p~n", [Code]),
      resolve_hash(Code, Req2),
      {ok, Req3} = cowboy_req:reply(404, [], Body, Req2),
      {ok, Req3, State};
    _ ->
      Body = ?DEFAULT_RESP,
      {ok, Req3} = cowboy_req:reply(404, [], Body, Req2),
      {ok, Req3, State}
  end.


resolve_hash(Hash, Req)->
  %lager:debug("resolving hash ~p~n", [Hash]),
  try
    Result= crypter:decrypt(Hash),
    send_file(<<"video/mp4">>, Result, Req)
  catch
    throw:Term -> Term;
    exit:Reason -> {exit, Reason};
    error:Reason -> {error,{Reason,erlang:get_stacktrace()}}
  end.

%send_file(<<"video/mp4">>, Path, Req);
%% @doc Send file by cowboy


send_file(Type, Path, Req) ->
  case file:read_file_info(Path) of
    {error, Err} ->
      lager:error("Can't send file ~s: ~p", [Path, Err]),
      cowboy_req:reply(404, Req);
    {ok, #file_info{size=Size, mtime=Time, type=regular}} ->
      Req1 = cowboy_req:set_resp_header(<<"content-type">>, Type, Req),
      Req2 = cowboy_req:set_resp_header(<<"last-modified">>, cowboy_clock:rfc2109(Time), Req1),
      Req3 = cowboy_req:set_resp_header(<<"content-length">>,
        list_to_binary(integer_to_list(Size)), Req2),
      Reply = cowboy_req:reply(200, Req3),
      file:sendfile(Path, cowboy_req:get(socket, Req3)),
      Reply
  end.

terminate(_Reason, _Req, _State) ->
  ok.

