-module(game_app).

-behaviour(application).

-export([start/2, stop/1]).
-include("common.hrl").

start(_StartType, _StartArgs) ->
    ?PRINT("_StartType = ~w, _StartArgs = ~w~n",[_StartType, _StartArgs]),
    case game_sup:start_link() of
        {ok, Pid} ->
            {ok, Pid};
        Other ->
            {error, Other}
    end.

stop(_State) ->
    ok.
