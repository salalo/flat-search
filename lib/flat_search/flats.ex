defmodule FlatSearch.Flats do
  @moduledoc """
  Flats context
  """
  alias FlatSearch.{Repo, Flats.Flat}

  def get_flat(id) do
    case Repo.get(Flat, id) do
      nil ->
        {:error, :not_found}

      flat ->
        {:ok, flat}
    end
  end

  def get_flat_by(params) do
    case Repo.get(Flat, params) do
      nil ->
        {:error, :not_found}

      flat ->
        {:ok, flat}
    end
  end

  def get_flats, do: Repo.all(Flat)

  def create_flat(attrs \\ %{}) do
    %Flat{}
    |> Flat.changeset(attrs)
    |> Repo.insert()
  end
end
