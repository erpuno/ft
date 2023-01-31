-module(dumper).
-export([parse_transform/2]).

parse_transform(Forms, _Options) ->
    io:format("Dump Forms: ~p",[Forms]),
    file:write_file("forms.erl",io_lib:format("~p",[Forms])),
    Forms.

