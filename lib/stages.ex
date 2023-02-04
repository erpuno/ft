defmodule Stages do

  def dis('Cr'),   do: 'Created'
  def dis('Det'),  do: 'Determination'
  def dis('C'),    do: 'Confirmation'
  def dis('A'),    do: 'Archive'
  def dis('gwC'),  do: 'gwConfirmation'
  def dis('InC'),  do: 'InitialConsideration'
  def dis('I'),    do: 'Implementation'
  def dis('R'),    do: 'Registration'
  def dis('gwND'), do: 'gwNeedsDetermination'
  def dis(x),      do: x

end
