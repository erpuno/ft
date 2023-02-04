defmodule Tests do

  # Test manually created AST forms

  def testForms() do
      testForm() |> FT.compileForms

      [{:routeProc, [], [], [], [], "approval", [:to], [], _, [], []}]
        = apply :inputProcTest2, :routeTo, [{:request, 'gwConfirmation', 'Implementation'}, []]
      [{:routeProc, [], [], [], [], "out", [:registered_by], [], [], [], []}]
        = apply :inputProcTest2, :routeTo, [{:request, 'Created', 'Registration'}, []]
  end

  # Test AST forms parsed from files

  def testFiles() do
      FT.load("bpe/org.bpe")        |> FT.compileFile |> FT.compileForms
      FT.load("bpe/internal.bpe")   |> FT.compileFile |> FT.compileForms
      FT.load("bpe/resolution.bpe") |> FT.compileFile |> FT.compileForms
      FT.load("bpe/output.bpe")     |> FT.compileFile |> FT.compileForms
      FT.load("bpe/input.bpe")      |> FT.compileFile |> FT.compileForms

      [{:routeProc, [], [], [], [], "approval", [:to], [], _, [], []}]
        = apply :input, :routeTo, [{:request, 'gwConfirmation', 'Implementation'}, []]
      [{:routeProc, [], [], [], [], "out", [:registered_by], [], [], [], []}]
        = apply :input, :routeTo, [{:request, 'Created', 'Registration'}, []]
  end

  # Run tests

  def run do
      testForms()
      testFiles()
      :passed
  end

  # Manually created AST sample

  def testForm do
      [
        FT.mod(:inputProcTest2),
        FT.compile_all(),
        FT.record(:routeProc, :lists.flatten(
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
        FT.routeFun(:routeTo, :lists.flatten(
           [{'gwConfirmation','Implementation',[{'approval', ['to'], [], {'Elixir.CRM.KEP','toExecutors'}}]},
            {'Created','Registration',[{'out', ['registered_by'], [], []}]}
           ])),
      ]
  end

end
