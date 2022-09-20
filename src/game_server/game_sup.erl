%%%-------------------------------------------------------------------
%%% @author xzj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%         游戏服务器监督者
%%% @end
%%% Created : 16. 9月 2022 17:22
%%%-------------------------------------------------------------------
-module(game_sup).

-include("common.hrl").

%% API
-export([
    start/0
    , stop/0
]).

start() ->
    start_normal_processes(init_modules_func()),
    ok.

stop() ->
    init:stop().

init_modules_func() ->
    [
        {mod_watchdog, start_link, []}          %% 看门狗服务
    ].

start_normal_processes([{Mod, _, _} = H | T]) ->
    {ok, _} = supervisor:start_child(game_sup, {H, H, permanent, 10000, worker, [Mod]}),
    start_normal_processes(T);
start_normal_processes([_H | T]) ->
    ?PRINT("[Error]:init_modules_func bad format: ~p~n", [_H]),
    start_normal_processes(T);
start_normal_processes([]) -> ok.