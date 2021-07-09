defmodule FlatSearch.Repo.Migrations.AddFlatRecordTable do
  use Ecto.Migration

  def change do
    create table("flat_record") do
      add :unique_id, :string
      add :link, :string
      add :price, :integer
      add :additional_price, :integer
      add :negotiation, :boolean
      add :surface, :integer
      add :description, :string
      add :favourite, :boolean
      add :state, :string
      add :photo_links, {:array, :string}

      timestamps
    end
  end
end
