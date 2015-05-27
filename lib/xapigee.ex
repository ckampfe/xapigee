defmodule Xapigee do
  def start(["from", filename]) do
    yaml_doc = Xapigee.Loader.load_yaml(filename)

    # build default.xml and get extract policies
    [{proxy_endpoint, policies}] =
      yaml_doc
      |> Enum.map(&Xapigee.Composer.build(&1, {[], []}))
      |> Enum.map(
           fn {doc, policies} ->
             {
               ["<ProxyEndpoint name=\"default\">\n"]
               ++ doc
               ++ ["</ProxyEndpoint>"],
               policies
             }
           end
         )


    IO.inspect policies
    IO.puts proxy_endpoint
  end
end
