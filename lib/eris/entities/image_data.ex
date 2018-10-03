defmodule Eris.Entities.ImageData do
  @moduledoc """
   Represents an image compatible with Discord's upload policies
  """
  @type t :: %Eris.Entities.ImageData{format: atom, data: binary}
  defstruct format: :jpg, data: ""


  @doc """
  decode - decode a data_uri into a the binary representation of the image, with a format marker
  """
  @spec decode(String.t) :: {:ok,  {atom, binary}} | {:error, atom}
  def decode(data_uri) do
    case ExDataURI.parse(data_uri) do
      {:error, _ } -> {:error, :invalid_data_uri}
      {:ok, mime, data} ->
        case mime_to_atom(mime) do
          {:ok, format} -> {:ok, {format, data}}
          err -> err
        end
    end
  end


  @doc """
  encode - given a format marker and an image loaded into memory, returns a data_uri
  """
  @spec encode(atom, binary) :: {:ok, String.t} | {:error, atom}
  def encode(format, image_binary) do
    case atom_to_mime(format) do
      {:ok, mime} ->
        case ExDataURI.encode(image_binary, mime, nil, :base64) do
          {:ok, result} -> {:ok, result}
          _ -> {:error, :encoding_failure}
        end
      err -> err
    end
  end

  # Converts mime_type to file type marking atom
  @spec mime_to_atom(String.t) :: {:ok | :error, atom}
  defp mime_to_atom(mime_type) do
    case mime_type do
      "image/jpeg" -> {:ok, :jpg}
      "image/gif" -> {:ok, :gif}
      "image/png" -> {:ok, :png}
      _ -> {:error, :invalid_mime_type}
    end
  end

  # Converts from the file type marker to the correct mime_type
  @spec atom_to_mime(atom) :: {:ok, String.t} | {:error, atom}
  defp atom_to_mime(atom) do
    case atom do
      :jpg -> {:ok, "image/jpeg"}
      :png -> {:ok, "image/png"}
      :gif -> {:ok, "image/gif"}
      _ -> {:error, :invalid_image_type}
    end
  end

end
