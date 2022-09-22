-module(main).
-export([start/0,stop/0]).

-include("common.hrl").
-define(APP, game).
-define(APPS, [kernel, stdlib, sasl,inets,ssl,?APP]).

-define(STOP_APPS, [stdlib, sasl,inets,ssl, ?APP]).

%% @doc 启动游戏
start() ->
    start_apps(?APPS),
    ok.

start_apps([]) ->
    ok;
start_apps([App | T]) ->
    ?PRINT("----------------- App  ~wStart~n",[App]),
    application:ensure_all_started(App),
    ?PRINT("----------------- App  ~w Start finish~n",[App]),
    start_apps(T).

%% @doc 结束游戏
stop() ->
    Apps = lists:reverse(?STOP_APPS),
    stop_apps(Apps),
    init:stop().

%% @doc 结束App
stop_apps(Apps) ->
    [catch stop_app(App) || App <- Apps].

stop_app(App) ->
    application:stop(App).