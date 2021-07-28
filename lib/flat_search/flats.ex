defmodule FlatSearch.Flats do
  @moduledoc """
  Flats context
  """
  alias FlatSearch.{Repo, Flats.Flat, Flats.PubSub}
  import Ecto.Query

  def get_flat(id) do
    case Repo.get(Flat, id) do
      nil ->
        {:error, :not_found}

      flat ->
        {:ok, flat}
    end
  end

  def get_flat_by(params) do
    case Repo.get_by(Flat, params) do
      nil ->
        {:error, :not_found}

      flat ->
        {:ok, flat}
    end
  end

  def get_flats, do: Repo.all(Flat)

  def get_flats_by(params, order_by) do
    params
    |> Enum.reduce(Flat, &generate_query(&1, &2, order_by))
    |> Repo.all()
  end

  defp generate_query({key, none}, query, _order_by) when none in ["", nil] or key == "order_by",
    do: query

  defp generate_query({"max_price", max_price}, query, order_by),
    do:
      from(q in query,
        where: q.price + q.additional_price <= ^String.to_integer(max_price),
        order_by: ^filter_order_by(order_by)
      )

  defp generate_query({key, value}, query, order_by) do
    from(q in query,
      where: field(q, ^String.to_existing_atom(key)) == ^value,
      order_by: ^filter_order_by(order_by)
    )
  end

  defp filter_order_by("surface_desc"), do: [desc: :surface]
  defp filter_order_by("surface_asc"), do: [asc: :surface]
  defp filter_order_by("price_desc"), do: [desc: :full_price]
  defp filter_order_by("price_asc"), do: [asc: :full_price]

  defp filter_order_by(_), do: []

  def create_flat(attrs \\ %{}) do
    %Flat{}
    |> Flat.changeset(attrs)
    |> Repo.insert()
    |> PubSub.broadcast(:flat_created)
  end
end
