defmodule FlatSearch.Flats do
  @moduledoc """
  Flats context
  """
  alias FlatSearch.{Repo, Flats.Flat}

  def get_flat(id) do
    with res when not is_nil(res) <-
           Repo.get(Flat, id) do
      {:ok, res}
    else
      _error -> {:error, :not_found}
    end
  end

  def get_flat_by(params) do
    with res when not is_nil(res) <-
           Repo.get_by(Flat, params) do
      {:ok, res}
    else
      _error -> {:error, :not_found}
    end
  end

  def get_flats, do: Repo.all(Flat)

  def create_flat(attrs \\ %{}) do
    %Flat{}
    |> Flat.changeset(attrs)
    |> Repo.insert()
  end
end
