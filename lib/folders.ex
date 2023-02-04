defmodule Folders do

  def dis('G'),   do: 'grouping'
  def dis('P'),   do: 'processed'
  def dis('C'),   do: 'certification'
  def dis('O'),   do: 'out'
  def dis('I'),   do: 'created'
  def dis('U'),   do: 'urgently'
  def dis('S'),   do: 'signing'
  def dis('T'),   do: 'tasks'
  def dis('A'),   do: 'agreement'
  def dis('V'),   do: 'approval'
  def dis('D'),   do: 'determination'
  def dis('N'),   do: 'sending'
  def dis('J'),   do: 'rejectedPersonal'
  def dis('R'),   do: 'resolutions'
  def dis('E'),   do: 'execution'
  def dis(x),     do: x

end
