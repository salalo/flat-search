defmodule FlatSearchWeb.PageLive do
  use FlatSearchWeb, :live_view

  alias FlatSearch.Filters.Filter

  @impl true
  def render(assigns), do: FlatSearchWeb.FlatView.render("page_live.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{changeset: Filter.changeset(%Filter{}, %{})})}
  end

  @impl true
  def handle_event("search", %{"filter" => params}, socket) do
    IO.inspect(params)
    IO.inspect(socket)

    # How to set parameters to the url dynamically???
    Crawly.Engine.start_spider(OlxScraper)
  end
end
