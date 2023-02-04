defmodule RouteProc do

  def folderField([]), do: []
  def folderField(folder), do: {:folder,FT.binary(folder)}

  def folderTypeField([]), do: {:folderType,FT.var('FT')}
  def folderTypeField('perm'), do: [{:folderType,FT.var('FT')},{:type,FT.atom(:permanent)}]
  def folderTypeField(ft), do: {:folderType,FT.binary(ft)}

  def usersField([]), do: []
  def usersField('[]'), do: []
  def usersField(users), do: {:users,FT.cons(:lists.map fn x -> FT.atom(x) end, users)}

  def callbackField([]), do: []
  def callbackField({mod,fun}), do: {:callback,FT.fun(FT.atom(mod),FT.atom(fun),2)}

end
