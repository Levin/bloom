defmodule Bloom do
  use GenServer
  require Logger
  @moduledoc """
  Documentation for `Bloom`.
    This is the first bloom filter written by me
  """

  # TODO: implement different hash functions
  # They all have to be in a range from 0 -> m-1 => find out what this means

  def new_value(value) do
    GenServer.cast(__MODULE__, {:val, value})
  end

  def info() do
    GenServer.call(__MODULE__, :info)
  end

  def start(size \\ 24) do
    GenServer.start_link(__MODULE__, size, name: __MODULE__)
  end

  def init(size) do
    raw_list = Enum.to_list(1..size)
    bitmap = Enum.map(raw_list, fn _ -> 0 end)
    state = %{filter: bitmap, size: size, current: nil, check_one: false, check_two: false, check_three: false}
    {:ok, state}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:val, value}, state) do
    change_one = mod(%{state|current: value})
    change_two = mul(change_one)
    change_three = binn(change_two)
    
    case already_in?(change_three) do
      true -> Logger.debug("[#{__MODULE__}] has this value already ")
      _ -> {:noreply, %{state | current: value, filter: change_two.filter}}
    end
  end

  
  def mod(state) do
    hash = rem(state.current, length(state.filter))
    {list, before} = activate_index(hash, state)

    case before == 1 do
      true -> %{state | filter: list, check_one: true}
      false -> %{state | filter: list}
    end
  end


  def mul(state) do
    c = :rand.uniform()*1
    m = trunc(state.current*c)
    hash = floor(length(state.filter) * (rem(m, 1)))
    {list, before} = activate_index(hash, state)

    case before == 1 do
      true -> %{state | filter: list, check_two: true}
      false -> %{state | filter: list}
    end
  end

  def binn(state) do
    hash = div(state.current, length(state.filter))
    {list, before} = activate_index(hash, state)
    case before == 1 do
      true -> %{state | filter: list, check_three: true}
      false -> %{state | filter: list}
    end
  end

  defp activate_index(hash, state) do
    value = Enum.at(state.filter, hash)
    {List.update_at(state.filter, hash, &(&1 = 1)), value}
  end

  defp already_in?(state) do
    case state.check_one && state.check_two && state.check_three do
      true -> true
      _ -> false 
    end
  end

end
