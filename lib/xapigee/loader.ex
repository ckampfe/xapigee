defmodule Xapigee.Loader do
  def load_yaml(file) do
    :yamerl_constr.file(file)
  end
end
