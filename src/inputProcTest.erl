-module(inputProcTest).
-compile({parse_transform, dumper}).
-include_lib("bpe/include/bpe.hrl").
-include_lib("schema/include/erp/catalogs/routeProc.hrl").
-compile(export_all).

% Erlang AST Sample Inspection

action(#messageEvent{name="X"} = Msg, #process{} = Proc) ->
    #result{type=stop, state=Proc};

action(#messageEvent{name="X"} = Msg, #process{userStarted = system} = Proc) ->
    #result{type=stop, state=Proc}.

routeTo({request, "gwConfirmation", "Implementation"}, FT) ->
    [#routeProc{folder= <<"approval">>,
                folderType= FT,
                users= [to],
                callback = fun 'Elixit.CRM.KEP':toExecutors/3}].
