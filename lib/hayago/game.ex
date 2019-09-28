defmodule Hayago.Game do
  alias Hayago.{ Game, State}
  use GenServer, restart: :transient


  defstruct history: [%State{}], index: 0

  @timeout 600_000

  # === Public API =====

  def start_link(options) do
    GenServer.start_link(__MODULE__, %Game{}, options)
  end

  # Returns the desired state from the list
  def state(%Game{history: history, index: index}), do: Enum.at(history, index)

  # === GenServer callbacks ===

  @impl true
  def init(game), do: {:ok, game, @timeout}

  @impl true
  def handle_call(:game, _from, game) do
    {:reply, game, game, @timeout}
  end

  @impl true
  def handle_cast({:place, position}, game) do
    {:noreply, Game.place(game, position), @timeout}
  end

  @impl true
  def handle_cast({:jump, destination}, game) do
    {:noreply, Game.jump(game, destination), @timeout}
  end

  @impl true
  def handle_info(:timeout, game), do: {:stop, :normal, game}

  # Updates the game by adding a new state at the top of th list
  def place(%Game{history: history, index: index} = game, position) do
    new_state = game |> Game.state() |> State.place(position)
    %{ game | history: [ new_state | Enum.slice(history, index.. -1)], index: 0 }
  end

  def jump(game, destination) do
    %{game | index: destination}
  end

  def history?(%Game{history: history}, index) when index >= 0 and length(history) > index do
    true
  end

  def history?(_game, _index), do: false

  def legal?(game, position) do
    is_legal = game |> Game.state() |> State.legal?(position)
    is_legal and not repeated_state?(game, position)
  end

  def repeated_state?(%Game{history: history}, _position) when length(history) <= 1, do: false

  def repeated_state?(game, position) do
    %Game{history: [%State{positions: tentative_positions} | history]} =
      Game.place(game, position)
    Enum.any?(history, fn %State{positions: positions} ->
      positions == tentative_positions
    end)
  end

end
