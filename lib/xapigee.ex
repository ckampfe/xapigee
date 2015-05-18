defmodule Xapigee do
  def start(["from", filename]) do
    yaml_doc = Loader.load_yaml(filename)

    tags =
      yaml_doc
      |> Enum.map(&Composer.build(&1, []))
      |> Enum.map(
           fn doc ->
             ["<ProxyEndpoint name=\"default\">\n"]
             ++ doc
             ++ ["</ProxyEndpoint>"]
           end
         )

    IO.puts tags
  end
end
