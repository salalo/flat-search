defmodule FlatSearchWeb.PageLive do
  use FlatSearchWeb, :live_view

  alias FlatSearch.{Filters, Filters.Filter, Flats}

  @impl true
  def render(assigns), do: FlatSearchWeb.FlatView.render("page_live.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{changeset: Filter.changeset(%Filter{}, %{})})}
  end

  @impl true
  def handle_event("search", %{"filter" => params}, socket) do
    changeset =
      %Filter{}
      |> Filters.change_filter(params)
      |> Map.put(:action, :insert)

    flats = Flats.get_flats()

    {:noreply, assign(socket, changeset: changeset, flats: flats)}
  end
end
