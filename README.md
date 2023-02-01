FT: FormalTalk ERP.UNO Compiler
===============================

[![Actions Status](https://github.com/erpuno/ft/workflows/mix/badge.svg)](https://github.com/erpuno/ft/actions)
[![Hex pm](https://img.shields.io/hexpm/v/ft.svg?style=flat)](https://hex.pm/packages/ft)

FormalTalk is the LEEX/YECC front-end to DSL of BPE, FORM and KVS
programming -- the core libraries of ERP.UNO State Enterprise open-source stack.

FT is the FormalTalk ERP.UNO compiler that compiles BPE and FORM
modules defined in FormalTalk language to BEAM byte-code that is
accessible from Erlang and Elixir environments. The type system
of FormalTalk in essense is an Erlang AST type system along with
record set from ERP.UNO schema.

The main purpose of FormalTalk is to provide an ability to
reconfiguration of processes and forms used in products:
`MIA:Документообіг`, `МІА:Зброя`, `МІА:Закупівлі`, `МІА:Провадження`
and others. This text format is also used as intermediary language
for business designer.

```
$ mix deps.get
$ iex -S mix
> :ft.console []
FormalTalk ERP.UNO Language INFOTECH SE 3.1.0

   Usage := :ft.console [ args <filename> ]
    args := command | command args
 command := parse | lex | read | fst | snd | file


 Sample: :ft.console ['parse','file','priv/kvs/person.kvs' ]
```

KVS module sample:

```
module person kvs
import location
import organization
record Person
begin id = seq 10 : term
    | cn = [] : [] + binary
    | name = [] : [] + binary
    | displayName = [] : [] + binary
    | location = [] : ERP.Loc
    | hours = 0 : integer
    | type = [] : term end

```

```
> :ft.console ['parse','file','priv/kvs/person.kvs' ]
{:ok,
 {:module, {:name, "person"}, {:kvs, 1},
  [
    {:import, {:name, "location"}},
    {:import, {:name, "organization"}},
    {:record, {:name, "Person"}, {:args, []},
     [
       decl: {:field, "id", ["seq", "10"], {:type, ["term"]}},
       decl: {:field, "cn", ["[]"], {:type, ["[]", "binary"]}},
       decl: {:field, "name", ["[]"], {:type, ["[]", "binary"]}},
       decl: {:field, "displayName", ["[]"], {:type, ["[]", "binary"]}},
       decl: {:field, "location", ["[]"], {:type, ["ERP.Loc"]}},
       decl: {:field, "hours", ["0"], {:type, ["integer"]}},
       decl: {:field, "type", ["[]"], {:type, ["term"]}}
     ]}
  ]}}
```


FORM module sample:

```
module inputForm form

event id begin ERP.inputOrder end

form new name doc:ERP.inputOrder options
begin pid = options.pid
    | user = options.user
    | regBind = orgPath user
    | pid = options.pid
    | corrOpt = options
    | corrOpt.postback = postback
    | corrOpt.required = true
    | coorOpt = dict
    | coorOpt.users = doc.coordination
    | document "inputOrder" name
    [ butOk title postback { postback :inputOrder doc.id pid }
    | butCancel "Скасувати" postback { :cancel postback :inputOrder doc.id pid }
    | butTemplate "Шаблон" postback { :templates :create :inputOrder } on postback=:create ]
    [ project comboLookup "Відхилено з коментарем"
    | urgent bool "Терміново" required
    | id string "Номер документа"
    | seq_id string "Унікальний номер"
    | to comboLookupVec "Первинний розгляд" CRM.Forms.Person regBind
    | nomenclature comboLookup "Номенклатура" CRM.Forms.DeedCat "/crm/deeds"
    | document_type string "Вид документа"
    | signed string "Підписав"
    | generic corr controlTask corrOpt
    | date calendar "Дата документа"
    | dueDate calendar "Термін виконання" min=:erlang.date() default=FormatDate.add_days(29)
    | note textarea "Примітка"
    | add_sheets number "К-ть аркушів додатків"
    | bizTask_initiator comboLookupVec CRM.Forms.Person "/acc"
    | modified_by comboLookupVec CRM.Forms.Person "/acc"
    | registered_by comboLookup "Реєстратор" required CRM.Forms.Person regBind default=user
    | generic topic controlTask corrOpt
    | generic coordination doc.coordination ] end

```

```
> :ft.console ['parse','file','priv/form/input.form' ]
{:ok,
 {:module, "inputForm", :form,
  [
    {:event, {:name, "id"}, [], [decl: {:call, ["ERP.inputOrder"]}]},
    {:form, {:name, "new"}, {:args, ["name", "doc:ERP.inputOrder", "options"]},
     [
       decl: {:assign, "pid", {:args, ["options.pid"]}},
       decl: {:assign, "user", {:args, ["options.user"]}},
       decl: {:assign, "regBind", {:args, ["orgPath", "user"]}},
       decl: {:assign, "pid", {:args, ["options.pid"]}},
       decl: {:assign, "corrOpt", {:args, ["options"]}},
       decl: {:assign, "corrOpt.postback", {:args, ["postback"]}},
       decl: {:assign, "corrOpt.required", {:args, ["true"]}},
       decl: {:assign, "coorOpt", {:args, ["dict"]}},
       decl: {:assign, "coorOpt.users", {:args, ["doc.coordination"]}},
       decl: {:document, "\"inputOrder\"", "name",
        {:buttons,
         [
           {:button, "butOk", "title",
            ["{", "postback", ":inputOrder", "doc.id", "pid", "}"]},
           {:button, "butCancel", "Скасувати",
            ["{", ":cancel", "postback", ":inputOrder", "doc.id", "pid", "}"]},
           {:button, "butTemplate", "Шаблон",
            ["{", ":templates", ":create", ":inputOrder", "}", "on",
             "postback=:create"]}
         ]},
        {:fields,
         [
           {:field, "project", "comboLookup",
            ["Відхилено з коментарем"]},
           {:field, "urgent", "bool", ["Терміново", "required"]},
           {:field, "id", "string", ["Номер документа"]},
           {:field, "seq_id", "string", ["Унікальний номер"]},
           {:field, "to", "comboLookupVec",
            ["Первинний розгляд", "CRM.Forms.Person", "regBind"]},
           {:field, "nomenclature", "comboLookup",
            ["Номенклатура", "CRM.Forms.DeedCat", "/crm/deeds"]},
           {:field, "document_type", "string", ["Вид документа"]},
           {:field, "signed", "string", ["Підписав"]},
           {:field, "generic", "corr", ["controlTask", "corrOpt"]},
           {:field, "date", "calendar", ["Дата документа"]},
           {:field, "dueDate", "calendar",
            ["Термін виконання", "min=:erlang.date()",
             "default=FormatDate.add_days(29)"]},
           {:field, "note", "textarea", ["Примітка"]},
           {:field, "add_sheets", "number",
            ["К-ть аркушів додатків"]},
           {:field, "bizTask_initiator", "comboLookupVec",
            ["CRM.Forms.Person", "/acc"]},
           {:field, "modified_by", "comboLookupVec",
            ["CRM.Forms.Person", "/acc"]},
           {:field, "registered_by", "comboLookup",
            ["Реєстратор", ...]},
           {:field, "generic", "topic", [...]},
           {:field, "generic", "coordination", ...}
         ]}}
     ]}
  ]}}
```

BPE module sample:

```
module input bpe

event action broadcastEvent begin result [ ] proc stop end
event action messageEvent process userStarted=system begin result [ ] proc stop end
event action messageEvent payload={next,*} begin output.bpe.action msg proc end
event action messageEvent name=DocumentStatistics payload=payload
begin call personal_stat proc.id executed payload | result [ ] proc stop end

event action messageEvent name=RemoveDocumentStatistics payload=payload
begin call remove_personal_stat proc.id executed payload | result [ ] proc stop end

event action messageEvent name=Implementation
begin doc = proc.docs.hd | doc.project = call projAction execute doc.project msg.payload []
    | proc.docs = [doc] | result [ next { proc.id } ] proc reply end

event action messageEvent name=Executed
begin result [ generate_history { executed proc.id msg.sender.id proc.docs.hd }
               spawn Elixir.History | next { proc.id } ] proc reply end

event action request to=Archive
begin newDoc = proc.docs.hd | newProc = proc | newProc.docs = [newDoc]
    | unindexUrgent proc newDoc | newState = call actionGen req proc newProc
    | result [ general req newState newDoc | stop ] newState reply proc.executors end

route routeTo
begin (Cr,R):R,[] | (R,gwND):O,R | (gwND,Det):D,[] | (*,InC):A,To
    | (gwC,I):A,To,toExecutors | (*,G):G,[];P,M | (*,A):A,[] end
```

```
{:event, {:name, "action"}, {:args, ["request", "to=gwRejected"]},
  [
    decl: {:assign, "newProc",{:args, ["call", "actionGen", "req", "proc", "proc"]}},
    decl: {:result,
      [
        cont: ["general", "req", "newPproc", "newDoc"],
        cont: ["next", "proc.id"]
      ], {:args, ["newProc", "reply", "proc.executors"]}}
  ]},
{:route, {:name, "routeTo"}, [],
  [
    decl: {:call, ["(Cr,R):R,[]"]},
    decl: {:call, ["(R,gwND):O,R"]},
    decl: {:call, ["(gwND,Det):D,[]"]},
    decl: {:call, ["(*,InC):A,To"]},
    decl: {:call, ["(gwC,I):A,To,toExecutors"]},
    decl: {:call, ["(*,G):G,[];P,M"]},
    decl: {:call, ["(*,A):A,[]"]}
  ]},
```

Mentions
--------

* <a href="https://tonpa.guru/stream/2023/2023-02-01%20FormalTalk.htm">FormatTalk: ERP.UNO Compiler</a>

Credits
-------

* Максим Сохацький, ДП "ІНФОТЕХ"
