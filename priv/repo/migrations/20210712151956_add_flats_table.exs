defmodule FlatSearch.Repo.Migrations.AddFlatsTable do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION citext", "DROP EXTENSION citext"

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
      add :region, :citext
      add :city, :citext
      add :district, :citext

      timestamps()
    end
  end
end
