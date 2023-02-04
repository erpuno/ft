defmodule Stages do

  def dis('Cr'),   do: 'Created'
  def dis('Det'),  do: 'Determination'
  def dis('C'),    do: 'Certification'
  def dis('S'),    do: 'SignatureImposition'
  def dis('Se'),   do: 'Send'
  def dis('S2'),   do: 'Sending'
  def dis('D'),    do: 'Development'
  def dis('Ag'),   do: 'Agreement'
  def dis('Cv'),   do: 'Convert'
  def dis('E'),    do: 'Execution'
  def dis('A'),    do: 'Archive'
  def dis('gwC'),  do: 'gwConfirmation'
  def dis('gwS'),  do: 'gwSigned'
  def dis('gwA'),  do: 'gwAgreed'
  def dis('gwR'),  do: 'gwRejected'
  def dis('gwV'),  do: 'gwConverted'
  def dis('InC'),  do: 'InitialConsideration'
  def dis('I'),    do: 'Implementation'
  def dis('IC'),   do: 'ImplementationControl'
  def dis('R'),    do: 'Registration'
  def dis('gwND'), do: 'gwNeedsDetermination'
  def dis('gwNC'), do: 'gwNeedsCertification'
  def dis(x),      do: x

end
