defmodule ElixirLearnPhoenix.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :thumbnail_url, :string
      add :price, :integer
      add :sold, :integer
      add :rating, :string
      timestamps(default: fragment("NOW()"))
    end
  end
end
