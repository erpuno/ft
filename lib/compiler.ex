defmodule FT do

  def boot(), do: Tests.compilePrivFolder

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
              x -> x
          end
          {:typed_record_field,{:record_field,1,atom(name),default},type}
          end, fields)
      {:attribute,1,:record,{recname,recfields}}
  end

  # routeProc{} onstructor invocation generation

  def routeProcInvoke(folder,users,folderType,callback) do
      {:record,1,:routeProc,
           :lists.map(fn {name,val} -> {:record_field,1,atom(name),val} end,
           :lists.flatten([ RouteProc.folderField(folder),
                            RouteProc.folderTypeField(folderType),
                            RouteProc.usersField(users),
                            RouteProc.callbackField(callback) ]))}
  end

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

  # Load and parse file

  def loadFile(file), do: :ft.console ['snd','load',[priv_dir(),priv_prefix(),file]]

  # Parse file and substutute imports in its declarations

  def load(file) when is_list(file), do: loadFileAndUnrollImports file
  def load(file) when is_binary(file), do: loadFileAndUnrollImports blist(file)
  def loadFileAndUnrollImports(file,dict \\ %{}) when is_list(file) do
      {:module,name,spec,decls} = loadFile(file)
      {:module,name,spec,unrollImports(decls, :maps.put(name,true,dict))}
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

  # Helpers

  def latom(x),      do: :erlang.list_to_atom x
  def alist(x),      do: :erlang.atom_to_list x
  def blist(x),      do: :erlang.binary_to_list x
  def priv_prefix(), do: :application.get_env(:ft,:priv_prefix,'/erp.uno/')
  def priv_dir(),    do: :application.get_env(:ft,:priv_dir,:code.priv_dir(:ft))

  # Compile Erlang AST forms to disk and reload

  def default(["[]"]), do: []
  def default([str]) when is_binary(str), do: binary(blist(str))
  def default(_), do: []

  def compileRecord(name,fields) do
      record(latom(blist(name)),
          :lists.map(fn {:field, name, defx, _type} ->
              {latom(blist(name)),default(defx),{:type,1,:term,[]}}
          end, fields))
  end

  def compileEvent(_name, _decls) do
      []
  end

  def compileNotice(_name, _decls) do
      []
  end

  def compileForm(_name, _decls) do
      []
  end

  def compileRoute(name,calls) do
      routeFun(latom(blist(name)), :lists.map(fn {:call,[y]} ->
          x = blist(y)
          [l,r] = case :string.tokens(x,':') do [a1,a2] -> [a1,a2] ; [a1] -> [a1,[]] end
          [s,d] = :string.tokens(:string.trim(l,:both,'()'),',')
          clauses = :string.tokens(r,';')
#         :io.format 'debug route: ~p~n', [{s,d,clauses}]
          {Stages.dis(s),Stages.dis(d),
              :lists.flatten(:lists.map(fn x ->
                 case :string.tokens(x,',') do
                      [] -> []
                      [_folder] -> []
                      [folder,users] -> {Folders.dis(folder),Fields.dis(users),[],[]}
                      [folder,users,callback] -> {Folders.dis(folder),Fields.dis(users),[],{'Elixir.CRM.KEP',callback}}
                      [folder,users,callback,folderType] -> {Folders.dis(folder),Fields.dis(users),folderType,{'Elixir.CRM.KEP',callback}}
                 end
              end, clauses))}
          end, calls))
  end

  def compileFile(file), do: compileFormalTalkFile(file)
  def compileFormalTalkFile(file) do
      {:module,name,spec,decls} = file
      [ mod(latom(alist(spec) ++ '.' ++ blist(name))), compile_all() ] ++
      :lists.flatten(:lists.map(fn
          {:record,{:name,name}, [], fields} -> compileRecord(name,fields)
          {:route,{:name,name}, [], calls} -> compileRoute(name,calls)
          {:event,{:name,name}, [], decls} -> compileEvent(name,decls)
          {:notice,{:name,name}, [], decls} -> compileNotice(name,decls)
          {:form,{:name,name}, [], decls} -> compileForm(name,decls)
          _ -> [] end, decls))
  end

  def compileErlangForms(ast, out), do: compileForms(ast, out)
  def compileForms(ast, out \\ 'priv/out/') do
      :filelib.ensure_dir out
      :code.add_pathz out
      case :compile.forms ast, [:debug_info,:return] do
         {:ok,name,beam,[{_,_warn}]} ->
#           :io.format 'warnings: ~p~n', [:erlang.element(3,hd(warn))]
           :file.write_file out ++ alist(name) ++ '.beam', beam
           :code.purge name
           :code.load_file name
           {name,beam}
         x ->
           :io.format 'errors: ~p~n', [x]
           {[],[]}
      end
  end

end
