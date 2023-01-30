-module(ft).
-vsn("3.1.0").
-copyright("FormalTalk ERP.UNO Language INFOTECH SE").
-export([init/1, start/2, stop/1, main/1, console/1]).

init([])   -> {ok, {{one_for_one, 5, 10}, []}}.
main(A)    -> console:unicode(), halt(console(A)).
start(_,_) -> console:unicode(), supervisor:start_link({local,?MODULE},?MODULE,[]).
stop(_)    -> ok.

console([]) ->
  io:format("~s ~s~n~n",
   [ proplists:get_value(copyright,module_info(attributes)),
     proplists:get_value(vsn,module_info(attributes))]),
  io:format("   Usage := :ft.console [ args <filename> ] ~n"),
  io:format("    args := command | command args ~n"),
  io:format(" command := parse | lex | read | fst | snd | file ~n~n~n"),
  io:format(" Sample: :ft.console ['parse','file','priv/forms/input.form' ]  ~n~n"),
   0;

console(S) ->
  lists:foldr(fun(I,Errors) -> R = lists:reverse(I),
    Res = lists:foldl(fun(X,A) -> console:(list_to_atom(lists:concat([X])))(A) end,hd(R),tl(R)),
%    io:format("~tp~n",[element(2,Res)]),
%    Errors + console:errcode(Res)
     Res
    end, 0, string:tokens(S,[","])).
