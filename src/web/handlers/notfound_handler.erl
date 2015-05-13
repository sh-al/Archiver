-module(notfound_handler).
-behaviour(cowboy_http_handler).
%% Cowboy_http_handler callbacks
-export([
  init/3,
  handle/2,
  terminate/3
]).

-include("../../archive.hrl").



init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->
  lager:error("Requested page not found"),
  Body = ?HTTP404,
  {ok, Req2} = cowboy_req:reply(404, [], Body, Req),
  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.