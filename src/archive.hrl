%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Apr 2015 12:11 AM
%%%-------------------------------------------------------------------
-author("Alexey Shilenkov").


-define(USERD(TERM), (fun(Termin) -> [User | _] = re:split(Termin, "[.]", [{return, binary}]), User end)(TERM)).
%%arch defines
%% index handler

-define(COWBOY_PORT, 8008).
-define(APACHE_PORT, "8090").

-define(DEFAULT_VIDEOROOT, "/tmp/videofs/").
-define(DEFAULT_FSTMP, <<"/tmp/">>).
-define(TMP_PATH, "/tmp/record_").
-define(FS_PATH, "fs/user/video_").


-define(DEFAULT_IMG, <<"/opt/service/fs/img/">>).

-define(USER_FS_ROOT, "/opt/service/fs/").

-define(POST, <<"POST">>).
-define(GET, <<"GET">>).
-define(PUT, <<"PUT">>).

-define(POST_RESP,<<"<h1>POST</h1>">>).
-define(GET_RESP,<<"<h1>GET</h1>">>).
-define(PUT_RESP,<<"<h1>PUT</h1>">>).
-define(DEFAULT_RESP, <<"<h1>response for other methods</h1>">>).

-define(HTTP404, <<"<h1>404 Page Not Found</h1>">>).


-define(MP4, ".mp4").

-define(PASS, <<"fj^g\"O1g94ng{">>).

-define(SAVE_THREADS_AMOUNT, 2).

-define(RECEIVE_WORKERS_NUM, 3).

%-define(CFG(Key), archive_app:get_config(Key, undefined)).


