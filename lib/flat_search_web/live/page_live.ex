defmodule FlatSearchWeb.PageLive do
  use FlatSearchWeb, :live_view
  alias FlatSearch.{Filters, Filters.Filter, Flats, Flats.PubSub}

  @impl true
  def render(assigns), do: FlatSearchWeb.FlatView.render("page_live.html", assigns)

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: PubSub.subscribe()

    {:ok,
     assign(socket, %{
       changeset: Filter.changeset(%Filter{}, %{}),
       flats: [],
       filters: [],
       locale: Map.get(session, "locale", "pl")
     })}
  end

  @impl true
  def handle_event("search", %{"filter" => params}, socket) do
    changeset =
      %Filter{}
      |> Filters.change_filter(params)
      |> Map.put(:action, :insert)

      ic_params = Enum.map(params, fn {key, value} -> {key, insensitive_string(value)} end)

    {:noreply,
     assign(socket,
       changeset: changeset,
       flats: Flats.get_flats_by(ic_params, params["order_by"]),
       filters: ic_params
     )}
  end

  @impl true
  def handle_info({:flat_created, flat}, socket) do
    case flat_fulfills_filters?(socket.assigns.filters, flat) do
      true ->
        {:noreply, assign(socket, flats: [flat] ++ socket.assigns.flats)}

      false ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:error, reason}, socket) do
    {:noreply, assign(socket, reason: reason)}
  end

  defp flat_fulfills_filters?(user_filters, flat_filters) do
    case check_list_truthy(key_exists_and_has_value(user_filters, flat_filters)) do
      false ->
        false

      true ->
        for {key, value} when value not in ["", nil] <- user_filters do
          case key do
            "max_price" ->
              String.to_integer(value) >= flat_filters[:price] + flat_filters[:additional_price]

            _ ->
              insensitive_string(Map.get(flat_filters, String.to_existing_atom(key))) ==
                insensitive_string(value)
          end
        end
        |> check_list_truthy()
    end
  end

  @spec key_exists_and_has_value(user_filters :: %{}, flat_filters :: %{}) :: [boolean(), ...]
  defp key_exists_and_has_value(user_filters, flat_filters) do
    user_filters
    |> Enum.reject(fn {_key, value} -> value in ["", nil] end)
    |> Enum.map(fn
      {"max_price", _value} ->
        Map.has_key?(flat_filters, :price) and Map.has_key?(flat_filters, :additional_price)

      {key, _value} ->
        Map.has_key?(flat_filters, String.to_existing_atom(key))
    end)
  end

  defp check_list_truthy(list), do: false not in list

  defp insensitive_string(string) when string in [nil, ""], do: ""

  defp insensitive_string(value) do
    value
    |> String.downcase()
    |> (&:iconv.convert("utf-8", "ascii//translit", &1)).()
    |> String.replace("'", "")
  end
end
