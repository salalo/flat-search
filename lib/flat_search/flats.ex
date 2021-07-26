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

  def get_flats_by(params) do
    params
    |> Enum.reduce(Flat, &generate_query(&1, &2))
    |> Repo.all()
  end

  defp generate_query({_, none}, query) when none in ["", nil],
    do: query

  defp generate_query({"max_price", max_price}, query),
    do: from(q in query, where: q.price + q.additional_price <= ^String.to_integer(max_price))

  defp generate_query({field, value}, query),
    do: where(query, ^[{String.to_existing_atom(field), value}])

  def create_flat(attrs \\ %{}) do
    %Flat{}
    |> Flat.changeset(attrs)
    |> Repo.insert()
    |> PubSub.broadcast(:flat_created)
  end
end
