{application, game,
    [{description, "A game server"},
        {vsn, "0.1.0"},
        {modules, [
            game_app,
            game_sup
        ]},
        {registered, [game_sup]},
        {applications, [kernel, stdlib]},
        {mod, {game_app, []}}
    ]}.
