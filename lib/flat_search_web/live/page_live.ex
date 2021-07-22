defmodule FlatSearchWeb.PageLive do
  use FlatSearchWeb, :live_view
  alias FlatSearch.{Filters, Filters.Filter, Flats, Flats.PubSub}

  @impl true
  def render(assigns), do: FlatSearchWeb.FlatView.render("page_live.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe()
    {:ok, assign(socket, %{changeset: Filter.changeset(%Filter{}, %{}), flats: []})}
  end

  @impl true
  def handle_info({:flat_created, flat}, socket) do
    {:noreply, assign(socket, flats: [flat] ++ socket.assigns.flats)}
  end

  @impl true
  def handle_info({:error, msg}, socket) do
    {:noreply, assign(socket, error: msg)}
  end

  @impl true
  def handle_event("search", %{"filter" => params}, socket) do
    changeset =
      %Filter{}
      |> Filters.change_filter(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset, flats: Flats.get_flats_by(params))}
  end
end
