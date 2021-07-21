defmodule FlatSearch.Repo.Migrations.AddFlatsTable do
  use Ecto.Migration

  def change do
    create table("flats") do
      add :unique_id, :string
      add :title, :string
      add :link, :string
      add :price, :integer
      add :additional_price, :integer
      add :negotiation, :boolean
      add :surface, :integer
      add :description, {:array, :text}
      add :favourite, :boolean
      add :state, :string
      add :photo_links, {:array, :string}
      add :region, :string
      add :city, :string
      add :district, :string

      timestamps()
    end
  end
end
