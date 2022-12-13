%%%-------------------------------------------------------------------
%%% @author xzj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%         套接字回调进程
%%% @end
%%% Created : 20. 10月 2022 19:22
%%%-------------------------------------------------------------------
-module(ws_handler).

-include("common.hrl").
-include("ws.hrl").

%% API
-export([
    init/2,
    check_status/0,
    websocket_handle/2,
    websocket_init/1,
    websocket_info/2,
    terminate/3
]).

init(Req, _Opts) ->
    ?PRINT("Req = ~w~n",[Req]),
    Peer = maps:get(peer, Req),
    ?PRINT("new client connect ip:~p~n", [Peer]),
    Ref = maps:get(ref, Req),
    ?PRINT("Ref = ~w~n",[Ref]),
%%  ?log("ws info:~p", [PortType]),
    {cowboy_websocket, Req, #ws_state{host=Peer}}.

websocket_init(State) ->
    ?PRINT("init data  : ~p~n", [State]),
    erlang:send_after(60000, self(), {loop}),
%%    lib_encryption:init(),
    erlang:start_timer(10000, self(), {?MODULE,check_status}),
    {[], State#ws_state{sid=self()}}.

websocket_handle({text, Msg}, State) ->
    ?PRINT("goo data : ~p", [Msg]),
    {[{text, << "That's what she said! ", Msg/binary >>}], State};
websocket_handle({binary, Bin}, State) ->
    ?PRINT("binary Bin  : ~p~n", [Bin]),
%%    lib_packet:handle_data(Bin, State),
%%  self() ! {send, <<"test">>},
    {[], State};
websocket_handle(Data, State) ->
    ?PRINT("unknow data : ~p", [Data]),
    {[], State}.

websocket_info({send, Data}, State) ->
%%  io:format("send client data : ~p", [Data]),
%%    EncryptInfo=lib_encryption:encrypt(Data),
%%    Bin=base:encode_msg(EncryptInfo),
    {[{binary, Data}], State};
%%{bind_socket, Pid,Uid,Name,HeroId}
websocket_info({bind_socket, Pid,Uid,Name,HeroId}, State) ->
    erlang:put(socket_status, true),
    NewState = State#ws_state{agent_pid = Pid, uuid = Uid,uid=Name,heroid = HeroId,sid=self()},
    {[], NewState};
websocket_info({heart_out_time, _}, State) ->
    {stop, State};
websocket_info({discon, _Reason}, State) ->
    {stop, State};
websocket_info({timeout, _TimerRef, {Module,Fun}}, State) ->
    Module:Fun(),
    {[], State};
websocket_info({timeout, _TimerRef, {Module,Fun,Arg}}, State) ->
    Module:Fun(Arg),
    {[], State};
websocket_info(stop, State) ->
    {stop, State};
websocket_info(_Info, State) ->
    ?PRINT("unknow msg : ~p", [_Info]),
    {[], State}.

%%terminate(_Reason, _Req, State) ->
%%    case Name =/= [] of
%%        true ->
%%            ets:delete(online, Name);
%%        _ ->
%%%%      ?log_error("ets delete online error uid:~p, host:~p~n", [UId, Host])
%%            skip
%%    end,
%%    handle_stop(gamePort,Pid),
%%    ok;
terminate(_Reason, _Req, _State) ->
    ?PRINT("_Reason = ~w, _Req = ~w, _State = ~w~n",[_Reason, _Req, _State]),
%%    handle_stop(PortType,Pid),
    ok.
%%send(Frames, State) ->
%%  cowboy_websocket:websocket_send(Frames, State).


%%=========================
%%        internal
%%=========================
handle_stop(gamePort, Pid) ->
    ok;
handle_stop(_PortType,_Pid) -> ok.

check_status()->
    case erlang:get(socket_status) of
        true->skip;
        _-> erlang:send(self(), {discon, time_out})
    end.
