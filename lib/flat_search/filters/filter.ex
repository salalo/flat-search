defmodule FlatSearch.Filters.Filter do
  @moduledoc """
  Filter module, non persistant schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  @default_params ~w(region city district street max_price)a

  schema "filters" do
    field :region, :string, virtual: true
    field :city, :string, virtual: true
    field :district, :string, virtual: true
    field :street, :string, virtual: true
    field :max_price, :integer, virtual: true
  end

  def changeset(filter, attrs) do
    filter
    |> cast(attrs, @default_params)
    |> validate_inclusion(:max_price, 1..100_000)
    |> validate_required(:max_price)
  end
end
