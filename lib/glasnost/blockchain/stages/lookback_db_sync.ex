defmodule Glasnost.Stage.LookbackBlocks do
  use GenStage
  alias Glasnost.Repo
  require Logger
  @blocks_per_tick 5
  @lookback_max_blocks 201_600

  def start_link(args, options) do
    GenStage.start_link(__MODULE__, args, options)
  end

  def init(%Glasnost.AgentConfig{} = config) do
    Logger.info("LookbackBlocks producer is initializing...")
    {:ok, %{head_block_number: head_block}} = config.client.get_dynamic_global_properties

    config = config
      |> Map.put_new(:starting_block, head_block)
      |> Map.put_new(:current_block, head_block)
    Process.send_after(self(), :next_blocks, 5_000)
    {:producer, config, dispatcher: GenStage.BroadcastDispatcher, buffer_size: 100_000}
  end

  def handle_demand(demand, state) do
    {:noreply, [], state}
  end

  def handle_info(:next_blocks, state) do
    import Ecto.Query
    Logger.info("Starting to import blocks from #{state.current_block}")
    cur_block  = state.current_block
    start_block = state.starting_block
    event_mod = Module.concat([state.client, Event])
    next_block = cur_block - @blocks_per_tick
    state = put_in(state.current_block, next_block)
    tasks_results = cur_block..next_block
      |> Enum.map(&Task.async(fn -> state.client.get_block(&1) end))
      |> Task.yield_many(10_000)

    blocks = for {_, {:ok, {:ok, block}}} <- blocks do
      struct(event_mod, %{data: block, metadata: %{}})
    end

    unless lookback_threshold_reached?(cur_block, start_block) do
      Process.send_after(self(), :next_blocks, 3_000)
    else
      Logger.info("Lookbacks stage finished extracting past blocks...")
    end
    {:noreply, blocks, state}
  end

  def lookback_threshold_reached?(cur_block, start_block) do
    cur_block > start_block - @lookback_max_blocks
  end


end
