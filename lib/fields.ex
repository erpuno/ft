defmodule Fields do

  def dis('[]'), do: []
  def dis(users) do
      :lists.flatten(:lists.map(fn char -> Fields.dispatch(char) end, users))
  end

  def dispatch(68), do: :to
  def dispatch(77), do: :modified_by
  def dispatch(82), do: :registered_by
  def dispatch(84), do: :target
  def dispatch(_ ), do: []

end
