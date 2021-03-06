require OK
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

  #Extracts returned message body and handles errors
  @spec handle_response(HTTPoison.Response) :: {:ok, String.t} | {:error, any}
  defp handle_response(response) do
    case response.status_code do
      # Both 201 and 200 are regular success codes
      code when code in [200, 201] -> {:ok, response.body}
      # 204 means we have a success with no response body
      204 -> {:ok, ""}
      # 304 means that no modification occurred to the underlying data
      304 -> {:ok, ""}
      # 400 means you have submitted an improperly formatted request
      400 -> {:error, :bad_request}
      # 401 means that you did not provide valid auth
      401 -> {:error, :invalid_auth}
      # 403 means that your token doesn't give you permissions to this object
      403 -> {:error, :not_permitted}
      # 404 means that the http resource does not exist
      404 -> {:error, :not_found}
      # 405 means that the method called does not work on this endpoint
      405 -> {:error, :not_allowed}
      # 429 means you have hit a ratelimit with this token, back-off
      429 -> {:error, :rate_limit}
      # 502 means that there is a no available gateway
      502 -> {:error, :gateway_unavailable}
      # Anything else means that discord's servers are having issues
      _ -> {:error, :discord_server_error}
    end
  end

  @doc """
    get_current_user - fetches the user associated with the token used to create this RestClient
    Parameters:
      * client_pid: pid.t - pid representing this client
  """
  @spec get_current_user(pid) :: {:ok, Eris.Entities.User.t} | {:error, atom}
  def get_current_user(client_pid) do
    OK.for do
      {base_url, headers} <- get_connection_info client_pid
      target_url = Path.join(base_url, "/users/@me")
      response <- HTTPoison.get(target_url, headers)
      body <- handle_response response
      user <- Poison.decode(body, as: %Eris.Entities.User{})
    after
      user
    end
  end

  @doc """
    get_user - fetches a user with a given snowflake id
    Parameters:
      * client_pid: pid.t - pid for the client
      * snowflake_id: Eris.Entities.Snowflake.t  - snowflake id for the target user
  """
  @spec get_user(pid, Eris.Entities.Snowflake.t) :: {:ok, Eris.Entities.User.t} | {:error, atom}
  def get_user(client_pid, user_id) do
    OK.for do
      {base_url, headers} <- get_connection_info client_pid
      target_url = Path.join(base_url, "/users/#{Eris.Entities.Snowflake.to_string(user_id)}")
      response <- HTTPoison.get(target_url, headers)
      body <- handle_response response
      user <- Poison.decode(body, as: %Eris.Entities.User{})
    after
      user
    end
  end

  @doc """
    modify_current_user - attempts to update the current user, allowing either avatar or username changes
    Parameters:
      * client_pid - pid for the running client
      * username - the new username for this user
      * avatar - the new avatar for this user
  """
  @spec modify_current_user(pid, String.t | nil,
   Eris.Entities.ImageData.t | nil) :: {:ok, Eris.Entities.User.t} | {:error, atom}
  def modify_current_user(client_pid, username \\ nil, avatar \\ nil) do
    OK.for do
      {base_url, headers} <- get_connection_info client_pid
      data = case {username, avatar} do
        {x, y} when x in ["", nil] and y in [nil, %Eris.Entities.ImageData{}] -> %{}
        {x, y} when x in ["", nil] -> %{"avatar" => y}
        {x, y} when y in [nil, %Eris.Entities.ImageData{}] -> %{"username" => x}
        _ -> %{"username" => username, "avatar" => avatar}
      end
      target_url = Path.join(base_url, "/users/@me")
      payload <- Poison.encode(data)
      response <- HTTPoison.patch(target_url, payload, headers)
      body <- handle_response response
      user <- Poison.decode(body, as: %Eris.Entities.User{})
    after
      user
    end
  end





end
