cd E:\git\game_server\script\ebin

set NUM_PROCESSES=102400

set TYPE_SMP=auto

set ETS_TABLES_MAX=100000

set ATOM_MAX=1000000


"C:\Program Files\erl10.7\bin\werl" -pa ../ebin -pa ../app -name  game_002@192.168.0.96 -boot start_sasl -smp auto +K true +P 1000000   -setcookie ct12 -s main start