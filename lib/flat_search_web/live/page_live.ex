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
    insensitive_string("Warszawą Dąbrowa")

    case flat_fulfills_filters?(socket.assigns.filters, flat) do
      true ->
        {:noreply, assign(socket, flats: [flat] ++ socket.assigns.flats)}

      false ->
        {:noreply, assign(socket, flats: socket.assigns.flats)}
    end
  end

  defp flat_fulfills_filters?(user_filters, flat_filters) do
    # compare only if key exists in flat_filters and user_filters key is not empty
    # enum return ok?
    key_exists_and_has_value? =
      Enum.each(user_filters, fn
        {_key, none} when none in ["", nil] ->
          false

        {key, _value} ->
          Map.has_key?(flat_filters, String.to_existing_atom(key))
      end)

    case key_exists_and_has_value? do
      false ->
        false

      # compare value case insensitive
      true ->
        Enum.each(user_filters, fn
          {key, value} ->
            flat_filters.(String.to_existing_atom(key)) == value
        end)
    end
  end

  defp insensitive_string(value) do
    value
    |> String.downcase()
    |> (&:iconv.convert("utf-8", "ascii//translit", &1)).()
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

    {:noreply,
     assign(socket, changeset: changeset, flats: Flats.get_flats_by(params), filters: params)}
  end
end
