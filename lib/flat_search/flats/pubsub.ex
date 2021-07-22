defmodule FlatSearch.Flats.PubSub do
  alias FlatSearch.PubSub
  @topic inspect(__MODULE__)

  def subscribe, do: Phoenix.PubSub.subscribe(PubSub, @topic)

  def broadcast({:ok, record}, event) do
    Phoenix.PubSub.broadcast(PubSub, @topic, {event, record})
    {:ok, record}
  end

  def broadcast({:error, _} = error, _event), do: error
end
