%%%-------------------------------------------------------------------
%%% @author xzj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%         websocket客户端
%%% @end
%%% Created : 13. 12月 2022 17:49
%%%-------------------------------------------------------------------
-module(ws_client).

-behaviour(gen_server).

%% API
-export([start/3,start/4,write/1,close/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
    terminate/2, code_change/3]).

-include("common.hrl").

%% Ready States
-define(CONNECTING,0).
-define(OPEN,1).
-define(CLOSED,2).

%% Behaviour definition
-export([behaviour_info/1]).

behaviour_info(callbacks) ->
    [{ws_onmessage,1},{ws_onopen,0},{ws_onclose,0},{ws_close,0},{ws_send,1}];
behaviour_info(_) ->
    undefined.

-record(state, {socket,readystate=undefined,headers=[],callback}).


%% ws_client:start("127.0.0.1",8051,ws_client).
start(Host,Port,Mod) ->
%%    start(Host,Port,"*",Mod).
    start(Host,Port,"/",Mod).

start(Host,Port,Path,Mod) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [{Host,Port,Path,Mod}], []).

init(Args) ->
    process_flag(trap_exit,true),
    [{Host,Port,Path,Mod}] = Args,
    {ok, Sock} = gen_tcp:connect(Host,Port,[binary,{packet, 0},{active,true}]),
    ?PRINT("Req = ~w~n",[Sock]),
    Req = initial_request(Host,Path),
    ?PRINT("Req = ~w~n",[Req]),
    ok = gen_tcp:send(Sock,Req),
    ?PRINT("11111111111111~n",[]),
    inet:setopts(Sock, [{packet, http}]),
    ?PRINT("22222222222222~n",[]),
    {ok,#state{socket=Sock,callback=Mod}}.

%% Write to the server
write(Data) ->
    gen_server:cast(?MODULE,{send,Data}).

%% Close the socket
close() ->
    gen_server:cast(?MODULE,close).

handle_cast({send,Data}, State) ->
%%    socket:send(State#state.socket, [0] ++ Data ++ [255]),
    gen_tcp:send(State#state.socket,"520" ++ Data),
    {noreply, State};
handle_cast(close,State) ->
    Mod = State#state.callback,
    Mod:ws_onclose(),
    gen_tcp:close(State#state.socket),
    State1 = State#state{readystate=?CLOSED},
    {stop,normal,State1}.

%% Start handshake
handle_info({http,Socket,{http_response,{1,1},101,_}}, State) ->
    ?PRINT("---------- 79 -------------- Socket = ~w~n",[Socket]),
    State1 = State#state{readystate=?CONNECTING,socket=Socket},
    {noreply, State1};
%% Extract the headers
handle_info({http,Socket,{http_header, _, Name, _, Value}},State) ->
    ?PRINT("---------- 83 -------------- Name = ~w, Value = ~w~n",[Name, Value]),
    case State#state.readystate of
        ?CONNECTING ->
            H = [{Name,Value} | State#state.headers],
            State1 = State#state{headers=H,socket=Socket},
            {noreply,State1};
        undefined ->
            %% Bad state should have received response first
            {stop,error,State}
    end;
%% Once we have all the headers check for the 'Upgrade' flag
handle_info({http,Socket,http_eoh},State) ->
    ?PRINT("----------- 95 --------------- State = ~w~n",[State]),
    %% Validate headers, set state, change packet type back to raw
    case State#state.readystate of
        ?CONNECTING ->
            Headers = State#state.headers,
            case proplists:get_value('Upgrade',Headers) of
                "websocket" ->
                    inet:setopts(Socket, [{packet, raw}]),
                    State1 = State#state{readystate=?OPEN,socket=Socket},
%%                    Mod = State#state.callback,
%%                    Mod:ws_onopen(),
                    {noreply,State1};
                _Any  ->
                    {stop,error,State}
            end;
        undefined ->
            %% Bad state should have received response first
            {stop,error,State}
    end;
%% Handshake complete, handle packets
handle_info({tcp, _Socket, Data},State) ->
    case State#state.readystate of
        ?OPEN ->
            ?PRINT("Data = ~w~n",[Data]),
%%            D = unframe(binary_to_list(Data)),
%%            Mod = State#state.callback,
%%            Mod:ws_onmessage(D),
            {noreply,State};
        _Any ->
            {stop,error,State}
    end;
handle_info({tcp_closed, _Socket},State) ->
    ?PRINT("-------------- tcp_closed -------------- ~n",[]),
%%    Mod = State#state.callback,
%%    Mod:ws_onclose(),
    {stop,normal,State};
handle_info({tcp_error, _Socket, _Reason},State) ->
    {stop,tcp_error,State};
handle_info({'EXIT', _Pid, _Reason},State) ->
    {noreply,State};
handle_info({http,Socket, Info},State) ->
    ?PRINT("Info = ~w~n, State = ~w~n",[Info, State]),
    State1 = State#state{readystate=?CONNECTING,socket=Socket},
    {noreply,State1};
handle_info(Info,State) ->
    ?PRINT("Info = ~w~n, State = ~w~n",[Info, State]),

    {noreply,State}.

handle_call(_Request,_From,State) ->
    {reply,ok,State}.

terminate(Reason, _State) ->
    error_logger:info_msg("Websocket Client Terminated ~p~n",[Reason]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------
initial_request(Host,Path) ->
%%    "OPTIONS "++ Path ++" HTTP/1.1\r\nUpgrade: WebSocket\r\nConnection: Upgrade\r\n" ++
        "GET "++ Path ++" HTTP/1.1\r\nupgrade: WebSocket\r\nconnection: Upgrade\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\nSec-WebSocket-Version: 13\r\n" ++
%%        "GET "++ Path ++" HTTP/1.1\r\nUpgrade: WebSocket\r\n" ++
        "Host: " ++ Host ++ "\r\n" ++
        "Origin: http://" ++ Host ++ "/\r\n\r\n" .
%%        "draft-hixie: 68".

unframe([0|T]) -> unframe1(T).

unframe1([255]) -> [];
unframe1([H|T]) -> [H|unframe1(T)].