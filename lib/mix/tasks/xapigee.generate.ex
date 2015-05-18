defmodule Mix.Tasks.Xapigee.Generate do
  use Mix.Task

  @shortdoc "Generate Apigee proxies"

  def run(args) do
    Application.start(:yamerl)
    Xapigee.start(args)
  end
end
