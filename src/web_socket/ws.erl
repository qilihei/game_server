-module(ws).
-include("common.hrl").

-export([start/0, start/2, stop/0, stop/1]).

-define(server_port, 8051).


start() ->
    start(http1, ?server_port),
    ?PRINT("start listen port: ~p", [?server_port]),
    ok.


start(Name, Port) ->
    Dispatch = cowboy_router:compile([{'_', [{"/", ws_handler, []}]}]),
    {ok, _} = cowboy:start_clear(Name, [{port, Port}], #{env => #{dispatch => Dispatch}}).


stop() ->
    stop(http1),
    ok.


stop(Name) ->
    cowboy:stop_listener(Name),

    ok.
