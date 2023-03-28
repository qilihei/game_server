%%%-------------------------------------------------------------------
%%% @author xzj
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%         排行版管理进程
%%% @end
%%% Created : 27. 3月 2023 21:05
%%%-------------------------------------------------------------------
-module(rank_mgr).
-behaviour(gen_server).


-include("rank.hrl").

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).


start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
    ets:new(?ets_rank_order, [ordered_set, public, {keypos, #rank_order.key}, {write_concurrency, true}]),
    ets:new(?ets_rank_text, [set, public, {keypos, #rank_order.key}, {write_concurrency, true}]),

    {ok, #rank_mgr_state{}}.


handle_call(_Request, _From, State = #rank_mgr_state{}) ->
    {reply, ok, State}.


handle_cast(_Request, State = #rank_mgr_state{}) ->
    {noreply, State}.


handle_info(_Info, State = #rank_mgr_state{}) ->
    {noreply, State}.


terminate(_Reason, _State = #rank_mgr_state{}) ->
    ok.


code_change(_OldVsn, State = #rank_mgr_state{}, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
