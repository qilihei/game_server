%%%-------------------------------------------------------------------
%%% @author xzj
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%         list测试
%%% @end
%%% Created : 28. 3月 2023 19:41
%%%-------------------------------------------------------------------
-module(rank_lists).

-include("rank.hrl").

-export([
    create_rank/2
    ,inset_test/2
    ,test/1

]).

unixtime() ->
    {M, S, _} = os:timestamp(),
    M * 1000000 + S.

create_rank(Num, State) ->
    F = fun(N, Acc) ->
        Info = #rank_info{id = N, value = N, text = lists:seq(0, N)},
        [Info | Acc]
        end,
    RankList = lists:foldl(F, [], lists:seq(1, Num)),
    {ok, State#rank_mgr_state{rank_list = RankList}}.

inset_test(N, State = #rank_mgr_state{rank_list = RankList}) ->
    Info = #rank_info{id = N, value = N, text = lists:seq(0, N)},
    NewRankList = test([Info, RankList]),
    NewState = State#rank_mgr_state{rank_list = NewRankList},
    {ok, NewState}.



test(RankList) ->
    NewRankList = sort(RankList),
    {_, Time1} = statistics(runtime),
    {_, Time2} = statistics(walk_clock),
    io:format("Time1 = ~w~n, Time2 = ~w~n",[Time1, Time2]),
    NewRankList.

sort(RankList) ->
    [ || RankList]
    do_sort([]).

check(#rank_info{value = Value1}, #rank_info{value = Value2}) ->
    Value1 > Value2.
