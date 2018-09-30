defmodule Eris.Entities.User do
@typedoc"""
Eris.Entities.User - defines a Discord user object
  Fields:
    * id: Eris.Entities.Snowflake - the user's id
    * username: String.t - the user's username (not unique)
    * discriminator: String.t -the user's 4-digit discord-tag
    * avatar: String.t | nil - the user's avatar hash
    * bot: boolean | nil -  whether this user is an OAuth app (bot)
    * mfa_enabled: boolean | nil -whether this user has 2FA enabled
    * locale: String.t | nil - the user's language option
    * verified: boolean | nil - whether the email on this account is verified
    * email: String.t | nil - the user's email
"""
@type t :: %Eris.Entities.User{
              id: Eris.Entities.Snowflake.t,
              username: String.t,
              discriminator: String.t,
              avatar: String.t | nil,
              bot: boolean | nil,
              mfa_enabled: String.t | nil,
              locale: String.t | nil,
              verified: boolean | nil,
              email: String.t | nil
            }

defstruct [:id, :username, :discriminator,
 :avatar, :bot, :mfa_enabled, :locale, :verified, :email]
end


defimpl Poison.Decoder, for: Eris.Entities.User do
  def decode(%{id: id} = user, _options) do
    case Eris.Entities.Snowflake.from_string(id) do
      {:ok, snowflake} -> %{user | id: snowflake}
      {:error, _} -> {:error, :invalid_snowflake}
    end
  end
end
