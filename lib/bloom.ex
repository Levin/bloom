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

  def hash_md5() do
    GenServer.cast(__MODULE__, :md5)
  end

  def hash_sha1() do
    GenServer.cast(__MODULE__, :sha1)
  end

  def hash_sha2() do
    GenServer.cast(__MODULE__, :sha2)
  end
  def info() do
    GenServer.call(__MODULE__, :info)
  end

  def start(size \\ 24_000) do
    GenServer.start_link(__MODULE__, size, name: __MODULE__)
  end

  def init(size) do
    raw_list = Enum.to_list(1..100)
    bitmap = Enum.map(raw_list, fn _ -> 0 end)
    state = %{filter: bitmap, size: size, current: nil, current_md5: nil, current_sha1: nil, current_sha2: nil}
    {:ok, state}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:val, value}, state) do
    {:noreply, %{state | current: value}}
  end

  def handle_cast(:md5, state) do
    hash = Base.encode16(:crypto.hash(:md5, state.current))
    {:noreply, %{state | current_md5: hash}}
  end

  def handle_cast(:sha1, state) do
    hash = Base.encode16(:crypto.hash(:sha1, state.current))
    {:noreply, %{state | current_sha1: hash}}
  end
  def handle_cast(:sha2, state) do
    hash = Base.encode16(:crypto.hash(:sha2, state.current))
    {:noreply, %{state | current_sha2: hash}}
  end


end
