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
    # field :description, {:array, :string}
    field :favourite, :boolean
    field :state, :string
    field :photo_links, {:array, :string}

    timestamps()

    def changeset(flat, attrs) do
      flat
      |> cast(attrs, [
        :title,
        :price,
        :link,
        :additional_price,
        :negotiation,
        :surface,
        # :description,
        :photo_links
      ])
      |> validate_required([
        :title,
        :price,
        :link,
        :photo_links
      ])
      |> put_link_hash()
    end

    defp put_link_hash(changeset) do
      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{link: link}} ->
          put_change(changeset, :unique_id, :crypto.hash(:md5, link) |> Base.encode16())

        _ ->
          changeset
      end
    end
  end
end
