defmodule FlatSearch.Flats do
  @moduledoc """
  Flats context
  """
  alias FlatSearch.{Repo, Flats.Flat}
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
    # TODO: Support max price
    # Search should not be case sensitive
    params
    |> Enum.reduce(Flat, fn
      {_field, none}, query when none in ["", nil] ->
        query

      {field, value}, query ->
        where(query, ^[{String.to_existing_atom(field), value}])
    end)
    |> Repo.all()
  end

  def create_flat(attrs \\ %{}) do
    %Flat{}
    |> Flat.changeset(attrs)
    |> Repo.insert()
  end
end
