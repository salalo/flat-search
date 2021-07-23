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
  def handle_event("search", %{"filter" => params}, socket) do
    changeset =
      %Filter{}
      |> Filters.change_filter(params)
      |> Map.put(:action, :insert)

    {:noreply,
     assign(socket, changeset: changeset, flats: Flats.get_flats_by(params), filters: params)}
  end

  @impl true
  def handle_info({:flat_created, flat}, socket) do
    case flat_fulfills_filters?(socket.assigns.filters, flat) do
      true ->
        {:noreply, assign(socket, flats: [flat] ++ socket.assigns.flats)}

      false ->
        {:noreply, assign(socket, flats: socket.assigns.flats)}
    end
  end

  @impl true
  def handle_info({:error, reason}, socket) do
    {:noreply, assign(socket, reason: reason)}
  end

  defp flat_fulfills_filters?(user_filters, flat_filters) do
    # Compare only if:
    # - key in flat_filters exist
    # - value that key points on in user_filters is not empty

    # support a case for price
    key_exists_and_has_value =
      for {key, value} when value not in ["", nil] <- user_filters do
        case key do
          "max_price" ->
            Map.has_key?(flat_filters, :price) and Map.has_key?(flat_filters, :additional_price)

          key ->
            Map.has_key?(flat_filters, String.to_existing_atom(key))
        end
      end

    case check_list_truthy(key_exists_and_has_value) do
      false ->
        false

      true ->
        for {key, value} when value not in ["", nil] <- user_filters do
          case key do
            "max_price" ->
              String.to_integer(value) >= flat_filters.price + flat_filters.additional_price

            _ ->
              insensitive_string(flat_filters[String.to_existing_atom(key)]) ==
                insensitive_string(value)
          end
        end
        |> check_list_truthy()
    end
  end

  defp check_list_truthy(list), do: false not in list

  defp insensitive_string(value) do
    value
    |> String.downcase()
    |> (&:iconv.convert("utf-8", "ascii//translit", &1)).()
  end
end
