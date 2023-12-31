defmodule Elixir115 do
  @moduledoc """
  Documentation for `Elixir115`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Elixir115.hello()
      :world

  """
  def main(args) do
    [path | _] = args
    result = Kernel.ParallelCompiler.compile([path], return_diagnostics: true)

    case result do
      {:ok, _modules,
        %{
          runtime_warnings: runtime_warnings,
          compile_warnings: compile_warnings
        }} ->
        dbg(compile_warnings)
        dbg(runtime_warnings)

      {:error, _errors, _warnings} ->
        nil
    end
  end
end
