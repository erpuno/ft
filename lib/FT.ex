defmodule FT do

  def cons([]), do: {:nil,1}
  def cons([x|t]), do: {:cons,1,x,cons(t)}
  def mod(name), do: {:attribute,1,:module,name}
  def compile_all(), do: {:attribute,1,:compile,:export_all}
  def binary(val), do: {:bin,1,[{:bin_element,1,{:string,1,val},:default,:default}]}
  def var(val), do: {:var,1,:erlang.list_to_atom(val)}
  def atom(val) when is_binary(val), do: atom(:erlang.binary_to_list(val))
  def atom(val) when is_atom(val), do: {:atom,1,val}
  def atom(val), do: {:atom,1,:erlang.list_to_atom(val)}
  def fun(mod,name,arity), do: {:fun,1,{:function,mod,name,{:integer,1,arity}}}
  def testFile(), do: :inputProc |> testFile |> compileForms

  def compileForms(ast) do
      {name,beam} = case :compile.forms ast, [:debug_info,:return] do
         {:ok,name,beam,_} ->
           :file.write_file :erlang.atom_to_list(name) ++ '.beam', beam
           :code.purge name
           :code.load_file name
           {name,beam}
         error ->
           {[],[]}
      end
  end

  def compile(file) do
      {:ok,[ast]} = :file.consult(file)
      compileForms ast
  end

  def schema(recname,recfields) do
      fields = :lists.map(fn {name,default,type} ->
         {:typed_record_field,{:record_field,1,{:atom,1,name},{:nil,1}},type}
         end, recfields)
      {:attribute,1,:record,{recname,fields}}
  end

  def routeCmd(name,folder,users,folderType,{mod,fun}) do
      usrs = :lists.map fn x -> {:atom,1,:erlang.list_to_atom(x)} end, users
      f = [{:folder,binary(folder)},
           {:folderType,var('FT')},
           {:users,cons(usrs)},
           {:callback,fun(atom(mod),atom(fun),2)}]
      fields = :lists.map fn {name,val} -> {:record_field,1,atom(name),val} end, f
      {:record,1,name,fields}
  end

  def routeClause(name,s,d,commands) do
      routeCommands = :lists.map fn {folder,users,folderType,callback} ->
         routeCmd(:routeProc,folder,users,folderType,callback) end, commands
      cmds = cons(routeCommands)
      {:clause,1,[{:tuple,1,[{:atom,1,:request},{:string,1,s},{:string,1,d}]},{:var,1,:'FT'}],[],[cmds]}
  end

  def route(name,clauses) do
      routeClauses = :lists.map fn {s,d,commands} -> routeClause(name,s,d,commands) end, clauses
      {:function,1,name,2,routeClauses}
  end

  def testFile(name) do
      [
        mod(name),
        compile_all(),
        schema(:routeProc, [{:id,[],{:type,1,:term,[]}},
                            {:operation,[],{:type,1,:term,[]}},
                            {:feed,[],{:type,1,:term,[]}},
                            {:type,[],{:type,1,:term,[]}},
                            {:folder,[],{:type,1,:term,[]}},
                            {:users,[],{:type,1,:term,[]}},
                            {:folderType,[],{:type,1,:term,[]}},
                            {:callback,[],{:type,1,:term,[]}},
                            {:reject,[],{:type,1,:term,[]}},
                            {:options,[],{:type,1,:term,[]}}
                           ]),
        route(:routeTo,[{'gwConfirmation','Implementation',
                       [{'approval', ['to'], [], {'Elixir.CRM.KEP','toExecutors'}}
                       ]}]),
      ]
  end

end
