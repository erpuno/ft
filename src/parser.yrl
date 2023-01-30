% Максим Сохацький ДП "ІНФОТЕХ"

mod -> 'module' name modspec 'begin' specs 'end' clauses : {module,'$2','$3','$5','$7'}.
modspec -> 'bpe' : '$1'.
modspec -> 'form' : '$1'.
clauses -> clause : ['$1'].
clauses -> clause clauses : ['$1'|'$2'].
clause -> 'event'  name args 'begin' decls 'end' : {event,  '$2', args('$3'), '$5'}.
clause -> 'route'  name args 'begin' decls 'end' : {route,  '$2', args('$3'), '$5'}.
clause -> 'form'   name args 'begin' decls 'end' : {form,   '$2', args('$3'), '$5'}.
clause -> 'notice' name args 'begin' decls 'end' : {notify, '$2', args('$3'), '$5'}.
args -> '$empty' : [].
args -> word args : ['$1'|'$2'].
name -> word : {name,name('$1')}.
spec -> 'form'   args : {form,'$2'}.
spec -> 'event'  args : {event,'$2'}.
spec -> 'route'  args : {route,'$2'}.
spec -> 'notice' args : {notify,'$2'}.
specs -> spec : [{spec,'$1'}].
specs -> spec '|' specs : [{spec,'$1'}|'$3'].
decl -> args : '$1'.
decl -> word '=' args : {assign,'$1','$3'}.
decl -> 'document' word word but_decl field_decl : {document,word('$2'),word('$3'),'$4','$5'}.
decl -> 'result' '[' decls ']' args : {result,'$3','$5'}.
decls -> decl : [{decl,'$1'}].
decls -> decl '|' decls : [{decl,'$1'}|'$3'].
field_decl -> '[' field_decl_inner ']' : {fields,'$2'}.
field_decl_inner -> args : [{field,'$1'}].
field_decl_inner -> args '|' field_decl_inner : [{field,'$1'}|'$3'].
but_decl -> '[' but_decl_inner ']' : {buttons,'$2'}.
but_decl_inner -> args : [{button,'$1'}].
but_decl_inner -> args '|' but_decl_inner : [{button,'$1'}|'$3'].

Rootsymbol mod.
Nonterminals mod spec clauses args clause name decl decls specs modspec but_decl field_decl but_decl_inner field_decl_inner.
Terminals word '=' '|' '[' ']' 'document' 'module' 'event' 'route' 'notice' 'form' 'bpe' 'begin' 'end' 'result'.
Erlang code.

word({_,_,Name}) -> Name.
name({_,_,Name}) -> Name.
args(A) -> args(lists:flatten([A]),[]).
args([],A) -> {args,lists:reverse(A)};
args([{name,Word}|T],A) -> args(T,[Word|A]);
args([{word,_,Word}|T],A) -> args(T,[Word|A]).

