defmodule Example do
  require Behaviour

  Behaviour.defcallback(init)

  def some_function() do
    HashDict.new()
    HashSet.member?(HashSet.new(), :foo)
  end
end
