defmodule Eris.Entities.ImageData do
  @moduledoc """
   Represents an image compatible with Discord's upload policies
  """
  @type t :: %Eris.Entities.ImageData{format: atom, data: binary}
  defstruct format: :jpg, data: ""

  

end
