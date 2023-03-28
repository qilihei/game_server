%%%-------------------------------------------------------------------
%%% @author xzj
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%         排行榜ordered_set
%%% @end
%%% Created : 27. 3月 2023 22:45
%%%-------------------------------------------------------------------
-module(rank_ets).
-include("rank.hrl").

%% API
-export([
    create_rank/1
    ,inset_test/2
    ,test/2

]).

unixtime() ->
    {M, S, _} = os:timestamp(),
    M * 1000000 + S.

create_rank(Num) ->
    F = fun(N) ->
        Order = #rank_order{key = {N, unixtime()}, id = N},
        Text = #rank_text{id = N, text = lists:seq(0, N)},
        ets:insert(?ets_rank_order, Order),
        ets:insert(?ets_rank_text, Text)
        end,
    lists:foreach(F, lists:seq(1, Num)).

inset_test(Id, Key) ->
    Order = #rank_order{key = {Key, unixtime()}, id = Id},
    Text = #rank_text{id = Id, text = lists:seq(0, Id)},
    ets:insert(?ets_rank_order, Order),
    ets:insert(?ets_rank_text, Text).

test(Id, Key) ->
    inset_test(Id, Key),
    F = fun(Order = #rank_order{id = Id}, {Rank, Acc}) ->
        NewOrder = Order#rank_order{rank = Rank},
        {Rank + 1, [NewOrder | Acc]}
        end,
    ets:foldl(F, {1, []}, ?ets_rank_order),
    {_, Time1} = statistics(runtime),
    {_, Time2} = statistics(walk_clock),
    io:format("Time1 = ~w~n, Time2 = ~w~n",[Time1, Time2]).



