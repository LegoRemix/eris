defmodule Eris.Entities.Emoji do
  @moduledoc """
  Eris.Entities.Emoji represents a single emoji on the Discord platform
  """

  defstruct [:id, :name, :roles, :user,
  :require_colons, :managed, :animated]


  @typedoc """
  %Eris.Entities.Emoji - in memory representation of an emoji
  Fields:
    * id: Eris.Entities.Snowflake.t - the id of this emoji
    * name: String.t - the name of this emoji
    * roles: [Eris.Snowflake.t] | nil - the list of roles which have access to this emoji
    * user: Eris.Entities.User.t | nil - the user who created this emoji
    * require_colons: booleans | nil - does this emote require colons to be used
    * managed: boolean | nil - is this emoji managed by an integration
    * animated: boolean | nil - is this emoji animated
  """
  @type t :: %Eris.Entities.Emoji{
    id: Eris.Entities.Snowflake.t | nil,
    name: String.t,
    roles: [Eris.Entities.Snowflake.t] | nil,
    user: Eris.Entities.User.t | nil,
    require_colons: boolean | nil,
    managed: boolean | nil,
    animated: boolean | nil,
  }
end


defimpl Poison.Decoder, for: Eris.Entities.Emoji do
  def decode(%{id: id} = emoji, _options) do
    case Eris.Entities.Snowflake.from_string(id) do
      {:ok, snowflake} -> {:ok, %{emoji | id: snowflake}}
      {:error, _} -> {:error, :invalid_snowflake}
    end
  end
end
