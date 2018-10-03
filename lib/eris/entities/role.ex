defmodule Eris.Entities.Role do
 @moduledoc """
  Eris.Entities.Role - represents a Discord Role as an elixir object
  IMPORTANT - Colors are represented as hex color codes in memory, but integers
  on the wire
 """

  @typedoc """
   Eris.Entities.Role - defines a Role object
   Fields:
   * id: Eris.Snowflake.t - the snowflake id for this role
   * name: String.t - the name of this role
   * color: String.t - integer representation of the hex color (0 == no color)
   * hoist: boolean - is this role pinned in the user listing
   * position: integer - the position of this role
   * permissions: integer - the permissions bits given by this role
   * managed: boolean - is this role managed by some 3rd party integration
   * mentionable: boolean - is this role mentionable in chat
  """
  @type t :: %Eris.Entities.Role{
    id: Eris.Entities.Snowflake.t,
    name: String.t,
    color: integer,
    hoist: boolean,
    position: integer,
    permissions: integer,
    managed: boolean,
    mentionable: boolean,
  }
  defstruct [:id, :name, :color,
   :hoist, :position, :permissions, :managed, :mentionable]
end


defimpl Poison.Decoder, for: Eris.Entities.Role do
  def decode(%{id: id, color: color} = role, _options) do
    case Eris.Entities.Snowflake.from_string(id) do
      {:ok, snowflake} -> {:ok, %{role | id: snowflake, color: Integer.to_string(color, 16)}}
      {:error, _} -> {:error, :invalid_snowflake}
    end
  end
end


defimpl Poison.Encoder, for: Eris.Entities.Role do
  def encode(role, options) do
    case Integer.parse(role.color, 16) do
      :error -> {:error, :invalid_color_code}
      {color, _} -> Poison.Encoder.Map.encode(%Eris.Entities.Role{role | color: color}, options)
    end
  end
end
