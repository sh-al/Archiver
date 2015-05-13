%%%-------------------------------------------------------------------
%%% @author Alexey Shilenkov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Feb 2014 10:23 PM
%%%-------------------------------------------------------------------
-module(crypter).
-author("Alexey Shilenkov").
-include("../archive.hrl").

%% API
-export([crypt/1, decrypt/1]).


%Pass1= base64:encode(?Pass),
%
%Path = /opt/portal/fs/u@u.xmpp2.feelinhome.ru/camName/XXXX_XXXX.asf.mp4
%
crypt(String)->
  Result = base64:encode(String),
  %lager:debug("crypt ~s~n", [Result]),
  Result.

decrypt(String)->
  Result = base64:decode(String),
  %lager:debug("crypt ~s~n", [Result]),
  Result.
