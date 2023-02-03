-module(ft).
-vsn("3.2.2").
-copyright(<<"FormalTalk: ERP.UNO Compiler © ДП «ІНФОТЕХ»"/utf8>>).
-export([init/1, start/2, stop/1, main/1, console/1]).

init([])   -> {ok, {{one_for_one, 5, 10}, []}}.
main(A)    -> console:unicode(), halt(console(A)).
start(_,_) -> console:unicode(), supervisor:start_link({local,?MODULE},?MODULE,[]).
stop(_)    -> ok.

console([]) ->
  io:format("~ts ~s~n~n",
   [ proplists:get_value(copyright,module_info(attributes)),
     proplists:get_value(vsn,module_info(attributes))]),
  io:format("   Usage := :ft.console [ cmds ] ~n"),
  io:format("    args := <empty> | <word> args ~n"),
  io:format("    cmds := <empty> | command args ~n"),
  io:format(" command := parse | lex | read | fst | snd | load | file ~n~n"),
  io:format(" Sample: :ft.console ['snd','load','priv/erp.uno/form/input.form']  ~n~n"),
  0;

console(S) ->
  lists:foldr(fun(I,_Errors) -> R = lists:reverse(I),
    lists:foldl(fun(X,A) -> console:(list_to_atom(lists:concat([X])))(A) end,hd(R),tl(R))
    end, 0, string:tokens(S,[","])).
