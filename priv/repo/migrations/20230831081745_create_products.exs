defmodule ElixirLearnPhoenix.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :slug, :text
      add :thumbnail_url, :string
      add :price, :bigint
      add :sold, :integer
      add :rating, :string
      timestamps(default: fragment("NOW()"))
    end
  end
end
