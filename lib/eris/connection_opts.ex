defmodule Eris.ConnectionOpts do
@typedoc """
Defines the connection options we can use to start a session with Discord
Parameters:
 * url - the Discord API URL to hit
 * token - A tuple containing one of the following tuples {:bot, TOKEN_STRING}, {:bearer, TOKEN_STRING}
"""

@type t :: %Eris.ConnectionOpts{url: String.t, token: {atom, String.t}}
defstruct url: "https://discordapp.com/api/v6", token: {:bot, ""}
end
