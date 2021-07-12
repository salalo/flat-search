defmodule FlatSearch.Flats do
  @moduledoc """
  Flats context
  """

  alias FlatSearch.{Repo, Flats.Flat}

  def create_flat(attrs \\ %{}) do
    %Flat{}
    |> Flat.changeset(attrs)
    |> Repo.insert()
    |> IO.inspect()
  end
end
