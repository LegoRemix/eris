require OK
import Eris.ConnectionOpts

defmodule Eris.RestClient do
  use Agent
  @moduledoc """
  Eris.RestClient provides an Elixir wrapper around the Discord API
  """

  @spec start_link(Eris.ConnectionOpts.t()) :: Agent.on_start
  def start_link(connection_opts) do
    Agent.start_link(fn -> %{base_url: connection_opts.url, state: %{}, token: connection_opts.token} end)
  end

  # Generates the authentication bearer from set of connection options
  defp make_auth_bearer(token)  do
    case token do
      {:bot, token} -> {:ok, "Bot #{token}"}
      {:bearer, token} -> {:ok, "Bearer #{token}"}
      _ -> {:error, :invalid_auth_token}
    end
  end


  defp make_request_headers(auth_header) do
    ["Authorization": auth_header, "Content-Type": "application/json"]
  end

  #Fetches the connection information we need to do any REST call
  defp get_connection_info(client_pid) do
    {base_url, token} = Agent.get(client_pid, fn store -> {store.base_url, store.token} end)
    OK.for do
      bearer <- make_auth_bearer token
      request_headers = make_request_headers bearer
    after
      {base_url, request_headers}
    end
  end

  @doc """
    get_current_user - fetches the user associated with the token used to create this RestClient
    Parameters:
      * client_pid  pid representing this client
  """
  @spec get_current_user(pid) :: {:ok, any} | {:error, any}
  def get_current_user(client_pid) do
    OK.for do
      {base_url, headers} <- get_connection_info client_pid
      target_url = Path.join(base_url, "/users/@me")
      result <- HTTPoison.get(target_url, headers)
    after
      result
    end
  end

end