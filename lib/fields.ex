defmodule Fields do

  def dis('[]'), do: []
  def dis(users) do
      :lists.flatten(:lists.map(fn char -> Fields.dispatch(char) end, users))
  end

  def dispatch(65), do: :approvers
  def dispatch(68), do: :to
  def dispatch(69), do: :executor
  def dispatch(73), do: :initiator
  def dispatch(77), do: :modified_by
  def dispatch(78), do: :target_notify
  def dispatch(82), do: :registered_by
  def dispatch(83), do: :signatory
  def dispatch(84), do: :target
  def dispatch(66), do: :bizTask_initiator
  def dispatch(_ ), do: []


end
