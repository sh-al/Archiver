-module(archive_app).

-behaviour(application).

%% Application callbacks
-export([start/2, start/0, stop/1 ]).
%deb http://packages.erlang-solutions.com/debian wheezy contrib
%apt-get install esl-erlang=1:16.b.1-1~debian~wheezy

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
  ok.

start(_StartType, _StartArgs) ->
  %load_config(),
  %%init modules
  application:start(syntax_tools),
  application:start(compiler),
  application:start(goldrush),
  application:start(lager),

  %init lager
  lager:start(),
  lager:set_loglevel(lager_console_backend, debug),
  lager:debug("START ARCHIVE_APP"),
  archive_sup:start_link().

stop(_State) ->
  ok.


%% get_config(Key, Default) ->
%%   case application:get_env(service, Key) of
%%     undefined -> Default;
%%     {ok, Val} -> Val
%%   end.

%% load_config() ->
%%   {ok, [[CfgFile]]} = init:get_argument(cfg),
%%   {ok, Config} = file:consult(CfgFile),
%%   [[application:set_env(App, K, V) || {K, V} <- Cfg]
%%     || {App, Cfg} <- Config].
