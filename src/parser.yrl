% Максим Сохацький ДП "ІНФОТЕХ"
mod -> 'module' name lib clauses : {module,'$2','$3','$4'}.
lib -> 'kvs' : '$1'.
lib -> 'bpe' : '$1'.
lib -> 'form' : '$1'.
clauses -> clause : ['$1'].
clauses -> clause clauses : ['$1'|'$2'].
clause -> 'import' name : {import, '$2'}.
clause -> 'record' name args 'begin' decls 'end' : {record, '$2', args('$3'), '$5'}.
clause -> 'event' name args 'begin' decls 'end' : {event, '$2', args('$3'), '$5'}.
clause -> 'route' name args 'begin' decls 'end' : {route, '$2', args('$3'), '$5'}.
clause -> 'form' name args 'begin' decls 'end' : {form, '$2', args('$3'), '$5'}.
clause -> 'notice' name args 'begin' decls 'end' : {notify, '$2', args('$3'), '$5'}.
args -> '$empty' : [].
args -> word args : ['$1'|'$2'].
name -> word : {name,name('$1')}.
union -> args : '$1'.
union -> args '+' union : {union,'$1','$3'}.
decl -> word '=' args ':' union : {field,name('$1'),arg(args('$3')),type(args(union('$5')))}.
decl -> word '=' args : {assign,word('$1'),args('$3')}.
decl -> args : {call,args('$1')}.
decl -> 'document' word word buttons fields : {document,word('$2'),word('$3'),'$4','$5'}.
decl -> 'result' '[' decls ']' args : {result,'$3','$5'}.
decls -> decl : [{decl,'$1'}].
decls -> decl '|' decls : [{decl,'$1'}|'$3'].
fields -> '[' field ']' : {fields,'$2'}.
field -> args : [field({field,args('$1')})].
field -> args '|' field : [field({field,args('$1')})|'$3'].
buttons -> '[' button ']' : {buttons,'$2'}.
button -> args : [button({button,args('$1')})].
button -> args '|' button : [button({button,args('$1')})|'$3'].
Rootsymbol mod.
Nonterminals mod lib clauses args clause name decl decls button field buttons fields union.
Terminals word '=' '+' ':' '|' '[' ']' 'module' 'import' 'begin' 'end' 'form' 'bpe' 'kvs'
               'event' 'route' 'notice' 'record' 'document' 'result'.
Erlang code.
word({_,_,Name}) -> Name.
name({_,_,Name}) -> Name.
arg({args,A}) -> A.
args(A) -> args(lists:flatten([A]),[]).
args([],A) -> {args,lists:reverse(A)};
args([{name,Word}|T],A) -> args(T,[Word|A]);
args([{word,_,Word}|T],A) -> args(T,[Word|A]).
field({field,{args,[Name,Type|Args]}}) -> {field,Name,Type,Args}.
button({button,{args,[Name,Title|Args]}}) -> {button,Name,Title,Args}.
union({union,Args,Right}) -> [Args|union(Right)];
union(A) -> A.
type({args,X}) -> {type,X}.

