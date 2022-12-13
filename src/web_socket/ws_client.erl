%%%-------------------------------------------------------------------
%%% @author xzj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%         socket客户端
%%% @end
%%% Created : 13. 12月 2022 17:49
%%%-------------------------------------------------------------------
-module(ws_client).

%% API
-export([
    connet/1
]).

connet(Message) ->
    {ok,Sock} = gen_tcp:connect("127.0.0.1",8051,[{active,true}, {packet,2}]),
    io:format("Sock = ~w~n",[Sock]),
    Return = gen_tcp:send(Sock,Message),
    io:format("Return = ~w~n",[Return]).
%%    A = gen_tcp:recv(Sock,0),
%%    io:format("A = ~w~n",[A]).
