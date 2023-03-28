%%%-------------------------------------------------------------------
%%% @author xzj
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%         排行头文件
%%% @end
%%% Created : 27. 3月 2023 21:58
%%%-------------------------------------------------------------------


%% ets表名称
-define(ets_rank_order, ets_rank_order).
-define(ets_rank_text, ets_rank_text).


-record(rank_order, {
    key = 0         %% 排序值
    ,id = 0         %% id
    ,rank = 0       %% 排名
}).

-record(rank_text, {
    id = 0          %% id
    ,text = []      %% 单体内容
}).

-record(rank_mgr_state, {
    rank_list = []      %% 排行列表 rank_info
}).

-record(rank_info, {
    id = 0                    %% id
    ,value = 0                %% 排序值
    ,rank = 0                 %% 排名
    ,text = []                %% 单体内容
}).