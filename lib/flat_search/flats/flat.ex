defmodule FlatSearch.Flats.Flat do
  @moduledoc """
  Flat module. Schema and changesets
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "flats" do
    field :unique_id, :string
    field :title, :string
    field :link, :string
    field :price, :integer
    field :additional_price, :integer
    field :negotiation, :boolean
    field :surface, :integer
    field :description, {:array, :string}
    field :favourite, :boolean
    field :state, :string
    field :photo_links, {:array, :string}

    timestamps()
  end
end
