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
    field :negotiation, :boolean, default: false
    field :surface, :integer
    field :description, {:array, :string}
    field :favourite, :boolean
    field :state, :string
    field :photo_links, {:array, :string}

    timestamps()

    def changeset(flat, attrs) do
      flat
      |> cast(attrs, [
        :title,
        :link,
        :price,
        :additional_price,
        :negotiation,
        :surface,
        :description,
        :photo_links
      ])
      |> validate_required([
        # :unique_id,
        :title,
        :link,
        :price,
        :photo_links
      ])
      |> unique_constraint([:unique_id, :link])
    end
  end
end
