defmodule Eris.Entities.Role do
 @moduledoc """
  Eris.Entities.Role - represents a Discord Role as an elixir object
 """

  @typedoc """
   Eris.Entities.Role - defines a Role object
   Fields:
   * id: Eris.Snowflake.t - the snowflake id for this role
   * name: String.t - the name of this role
   * color: integer - integer representation of this color the hex color code (0 == no color)
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
  def decode(%{id: id} = role, _options) do
    case Eris.Entities.Snowflake.from_string(id) do
      {:ok, snowflake} -> {:ok, %{role | id: snowflake}}
      {:error, _} -> {:error, :invalid_snowflake}
    end
  end
end
