%%%-------------------------------------------------------------------
%%% @author xzj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 10月 2022 19:32
%%%-------------------------------------------------------------------

-record(ws_state, {
    uuid=0,
    uid = "",
    host="",
    heroid=0,
    sid=0,
    agent_pid=0,
    scene_pid=0,
    ws_socket,
    robot_online = 0,
    port_type = 'gamePort',
    timer_ref
}).