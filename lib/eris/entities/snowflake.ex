use Bitwise, only_operators: true
require OK

defmodule Eris.Entities.Snowflake do
  @epoch 1420070400000

  @type t :: %Eris.Entities.Snowflake{timestamp: DateTime.t, worker: integer, process: integer, increment: integer}
  defstruct timestamp: DateTime.utc_now(), worker: 0, process: 0, increment: 0

  @spec from_string(String.t) :: {:ok, Eris.Entities.Snowflake.t} | {:error, atom}
  def from_string(str) do
    case Integer.parse(str) do
      :error -> {:error, :invalid_snowflake}
      {snowflake, _} -> OK.for do
        ms_since_epoch = (snowflake >>> 22) + @epoch
        worker = (snowflake &&& 0x3E0000) >>> 17
        process = (snowflake &&& 0x1F000) >>> 12
        increment = snowflake &&& 0xFFF
        timestamp <- DateTime.from_unix(ms_since_epoch, :millisecond)
        after
          %Eris.Entities.Snowflake{
           timestamp: timestamp,
           worker: worker,
           process: process,
           increment: increment
         }
        end
    end
  end

  @spec from_string!(String.t) :: Eris.Entities.Snowflake
  def from_string!(str) do
    case from_string(str) do
      {:ok, snowflake} -> snowflake
      _ -> raise Eris.Entities.SnowflakeParseError, message: "could not parse #{inspect(str)} into snowflake"
    end
  end
end
