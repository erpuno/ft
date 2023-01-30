FT: FormalTalk ERP.UNO Compiler
===============================

FormalTalk is the DSL designed to cover the needs of BPE,
FORM and KVS programming -- the core libraries of ERP.UNO
State Enterprise open-source stack.

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


 Sample: :ft.console ['parse','file','priv/forms/input.form' ]
```

FormalTalk AST:

```
> :ft.console ['parse','file','priv/procs/input.bpe' ]
{:module, {:name, "input"}, {:bpe, 1},
...
    {:route, {:name, "routeFrom"}, {:args, []},
     [
       decl: [{:word, 80, "(R,gwND):R,[]"}],
       decl: [{:word, 80, "(Det,InC):D,[]"}],
       decl: [{:word, 80, "(InC,I):A,To,fromExecutors"}],
       decl: [{:word, 80, "(I,gwC):A,To,fromExecutors"}],
       decl: [{:word, 81, "(gwR,I):G,[]"}],
       decl: [{:word, 81, "(*,G):A,To"}],
       decl: [{:word, 81, "(*,A):G,[];O,R;U,RTo;R,[];D,[]"}]
     ]}
  ]}}
```

BPE module sample:

```
module input bpe
begin event action msg proc
    | route routeTo req ft
    | route routeFrom req ft
    | notice notify req end

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
begin result [ generate_history { executed proc.id msg.sender.id proc.docs.hd } spawn Elixir.History
             | next { proc.id } ] proc reply end

event action request to=Archive
begin newDoc = proc.docs.hd | newProc = proc | newProc.docs = [newDoc]
    | unindexUrgent proc newDoc | newState = call actionGen req proc newProc
    | result [ general req newState newDoc | stop ] newState reply proc.executors end

route routeTo
begin (Cr,R):R,[] | (R,gwND):O,R | (gwND,Det):D,[] | (*,InC):A,To
    | (gwC,I):A,To,toExecutors | (*,G):G,[];P,M | (*,A):A,[] end
```

FORM module sample:

```
module inputForm form
begin form new name doc options
    | event id end

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
          [ butOk            title postback { postback :inputOrder doc.id pid }
          | butCancel  "Скасувати" postback { :cancel postback :inputOrder doc.id pid }
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
{:fields,
  [field: [{:word, 21, "project"},
           {:word, 21, "comboLookup"},
           {:word, 21, "\"Відхилено з коментарем\""}],
   field: [{:word, 22, "urgent"},
           {:word, 22, "bool"},
           {:word, 22, "\"Терміново\""},
           {:word, 22, "required"}],
```

Credits
-------

* Максим Сохацький, ДП "ІНФОТЕХ"
