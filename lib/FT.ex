defmodule FT do

  # FormalTalk ERP.UNO Compiler 3.2.2
  #
  # Supported code generators:
  # [x] module
  # [x] route
  # [x] import
  # [ ] notice
  # [ ] fun
  # [ ] form

  # Erlang AST definitions

  def cons([]), do: {:nil,1}
  def cons([x|t]), do: {:cons,1,x,cons(t)}
  def mod(name), do: {:attribute,1,:module,name}
  def compile_all(), do: {:attribute,1,:compile,:export_all}
  def string(val), do: {:string,1,val}
  def integer(val), do: {:integer,1,val}
  def binary(val), do: {:bin,1,[{:bin_element,1,string(val),:default,[:utf8]}]}
  def var(val), do: {:var,1,latom(val)}
  def atom(val) when is_atom(val), do: {:atom,1,val}
  def atom(val) when is_list(val), do: {:atom,1,latom(val)}
  def fun(mod,name,arity), do: {:fun,1,{:function,mod,name,integer(arity)}}

  # Imported module records

  def record(recname,fields) do
      recfields = :lists.map(fn {name,defx,type} ->
          default = case defx do
              [] -> cons([])
              x when is_integer(x) -> integer(x)
              x when is_list(x) -> string(x)
              x when is_binary(x) -> binary(blist(x))
          end
          {:typed_record_field,{:record_field,1,atom(name),default},type}
          end, fields)
      {:attribute,1,:record,{recname,recfields}}
  end

  # routeProc{} onstructor invocation generation

  def routeProcInvoke(folder,users,folderType,callback) do
      args = [ folderField(folder),
               folderTypeField(folderType),
               usersField(users),
               callbackField(callback)
             ]
      fields = :lists.map fn {name,val} -> {:record_field,1,atom(name),val} end, :lists.flatten args
      {:record,1,:routeProc,fields}
  end

  def folderField([]), do: []
  def folderField(folder), do: {:folder,binary(folder)}

  def folderTypeField([]), do: {:folderType,var('FT')}
  def folderTypeField(ft) when is_binary(ft), do: {:folderType,binary(blist(ft))}

  def usersField([]), do: []
  def usersField(users), do: {:users,cons(:lists.map fn x -> atom(x) end, users)}

  def callbackField([]), do: []
  def callbackField({mod,fun}), do: {:callback,fun(atom(mod),atom(fun),2)}

  # Route clause generator

  def routeClause(src,dst,commands) do
      cmds = :lists.map fn {folder,users,folderType,callback} ->
             routeProcInvoke(folder,users,folderType,callback) end, commands
      {:clause,1,[{:tuple,1,[atom(:request),string(src),string(dst)]},var('FT')],[],[cons(cmds)]}
  end

  # Route function generator

  def routeFun(name,clauses) do
      routeClauses = :lists.map fn {s,d,cmds} -> routeClause(s,d,cmds) end, clauses
      {:function,1,name,2,routeClauses}
  end

  # Compile Erlang AST forms to disk and reload

  def compileFile(file \\ testFile()) do
      :io.format 'compile: ~ts.~ts~n', [:erlang.element(2,file), :erlang.element(3,file)]
      testForms()
  end

  def compileForms(ast, out \\ 'priv/out/') do
      :filelib.ensure_dir out
      :code.add_pathz out
      case :compile.forms ast, [:debug_info,:return] do
         {:ok,name,beam,[{_,warn}]} ->
           :io.format 'warnings: ~p~n', [warn]
           :file.write_file out ++ alist(name) ++ '.beam', beam
           :code.purge name
           :code.load_file name
           {name,beam}
         _ ->
           {[],[]}
      end
  end

  # Substitute imports in file declarations

  def unrollImports(decls,d) do
      {acc,_} = :lists.foldl(
          fn {:import,import}, {acc,dict} ->
               case :maps.get(latom(blist(import)),dict,[]) do
                  true -> {acc,dict}
                     _ -> {_,_,_,dec} = loadFileAndUnrollImports(blist(import),dict)
                          {acc++dec,:maps.put(latom(blist(import)),true,dict)} end
             x, {acc,dict} -> {acc++[x],dict} end, {[],d}, decls)
      :lists.flatten(acc)
  end

  # Load and parse file

  def loadFile(file), do: :ft.console ['snd','load',[priv_dir(),priv_prefix(),file]]

  # Parse file and substutute imports in its declarations

  def loadFileAndUnrollImports(file,dict \\ %{}) when is_list(file) do
      {:module,name,spec,decls} = loadFile(file)
      {:module,name,spec,unrollImports(decls, :maps.put(name,true,dict))}
  end

  def latom(x),      do: :erlang.list_to_atom x
  def alist(x),      do: :erlang.atom_to_list x
  def blist(x),      do: :erlang.binary_to_list x
  def priv_prefix(), do: '/erp.uno/'
  def priv_dir(),    do: :code.priv_dir(:ft)

  # Sample AST form of route function generation

  def tests() do
      testForms() |> compileForms
      testFile() |> compileFile |> compileForms
      [{:routeProc, [], [], [], [], "approval", [:to], [], _, [], []}]
        = apply :inputProc, :routeTo, [{:request, 'gwConfirmation', 'Implementation'}, []]
      [{:routeProc, [], [], [], [], "out", [:registered_by], [], [], [], []}]
        = apply :inputProc, :routeTo, [{:request, 'Created', 'Registration'}, []]
      :passed
  end

  def testFile(file \\ 'bpe/input.bpe'), do: loadFileAndUnrollImports file
  def testForms do
      [
        mod(:inputProc),
        compile_all(),
        record(:routeProc, :lists.flatten(
           [{:id,[],{:type,1,:list,[]}},
            {:operation,[],{:type,1,:term,[]}},
            {:feed,[],{:type,1,:term,[]}},
            {:type,[],{:type,1,:term,[]}},
            {:folder,[],{:type,1,:term,[]}},
            {:users,[],{:type,1,:term,[]}},
            {:folderType,[],{:type,1,:term,[]}},
            {:callback,[],{:type,1,:term,[]}},
            {:reject,[],{:type,1,:term,[]}},
            {:options,[],{:type,1,:term,[]}}
           ])),
        routeFun(:routeTo, :lists.flatten(
           [{'gwConfirmation','Implementation',[{'approval', ['to'], [], {'Elixir.CRM.KEP','toExecutors'}}]},
            {'Created','Registration',[{'out', ['registered_by'], [], []}]}
           ])),
      ]
  end

end
