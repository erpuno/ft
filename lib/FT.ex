defmodule FT do

  # FormalTalk ERP.UNO Compiler 3.1.0
  #
  # Supported code generators:
  # [x] module
  # [x] route
  # [x] import
  # [ ] notice
  # [ ] event
  # [ ] form

  # Erlang AST definitions

  def latom(x), do: :erlang.list_to_atom x
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
  def fun(mod,name,arity), do: {:fun,1,{:function,mod,name,{:integer,1,arity}}}
  def testFile(), do: :inputProc |> testFile |> compileForms

  # Imported module records

  def record(recname,recfields) do
      fields = :lists.map(fn {name,default,type} ->
          defx = case default do
              [] -> cons([])
              x when is_integer(x) -> integer(x)
              x when is_list(x) -> string(x)
              x when is_binary(x) -> binary(:erlang.binary_to_list(x))
          end
          {:typed_record_field,{:record_field,1,atom(name),defx},type}
          end, recfields)
      {:attribute,1,:record,{recname,fields}}
  end

  # routeProc{} onstructor invocation generation

  def routeProcInvoke(folder,users,folderType,{mod,fun}) do
      usrs = :lists.map fn x -> atom(x) end, users
      ft = case folderType do
          [] -> var('FT')
          x when is_binary(x) -> binary(:erlang.binary_to_list(x))
      end
      args = [{:folder,binary(folder)},
              {:folderType,ft},
              {:users,cons(usrs)},
              {:callback,fun(atom(mod),atom(fun),2)}]
      fields = :lists.map fn {name,val} -> {:record_field,1,atom(name),val} end, args
      {:record,1,:routeProc,fields}
  end

  # Route clause generator

  def routeClause(s,d,commands) do
      routeCommands = :lists.map fn {folder,users,folderType,callback} ->
          routeProcInvoke(folder,users,folderType,callback) end, commands
      cmds = cons(routeCommands)
      {:clause,1,[{:tuple,1,[atom(:request),string(s),string(d)]},var('FT')],[],[cmds]}
  end

  # Route function generator

  def routeFun(name,clauses) do
      routeClauses = :lists.map fn {s,d,cmds} -> routeClause(s,d,cmds) end, clauses
      {:function,1,name,2,routeClauses}
  end

  # Compile AST form to disk and reload

  def compileForms(ast) do
      :filelib.ensure_dir 'priv/out/'
      case :compile.forms ast, [:debug_info,:return] do
         {:ok,name,beam,_} ->
           :file.write_file 'priv/out/' ++ :erlang.atom_to_list(name) ++ '.beam', beam
           :code.purge name
           :code.load_file name
           {name,beam}
         _ ->
           {[],[]}
      end
  end

  # Sample AST form of route function generation

  def testFile(name) do
      [
        mod(name),
        compile_all(),
        record(:routeProc, [{:id,[],{:type,1,:list,[]}},
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
        routeFun(:routeTo, [{'gwConfirmation','Implementation',
                           [{'approval', ['to'], [], {'Elixir.CRM.KEP','toExecutors'}}
                           ]}]),
      ]
  end

end
