-module(dumper).
-export([parse_transform/2]).

parse_transform(Forms, _Options) ->
    io:format("Dump Forms: ~p",[Forms]),
    Forms.

