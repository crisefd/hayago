defmodule Hayago.Game do
  alias Hayago.{ Game, State}
  # A game's history is a list of states
  defstruct history: [%State{}], index: 0

  # Returns the desired state from the list
  def state(%Game{history: history, index: index}), do: Enum.at(history, index)

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
