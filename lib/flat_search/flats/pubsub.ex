defmodule FlatSearch.Flats.PubSub do
  alias FlatSearch.PubSub
  @topic inspect(__MODULE__)

  def subscribe, do: Phoenix.PubSub.subscribe(PubSub, @topic)

  def broadcast({:ok, record}, event) do
    Phoenix.PubSub.broadcast(PubSub, @topic, {event, record})
    {:ok, record}
  end

  def broadcast({:error, _} = error, _event), do: error

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(PubSub, @topic, {__MODULE__, event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _), do: {:error, reason}
end