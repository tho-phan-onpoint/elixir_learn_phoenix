defmodule ElixirLearnPhoenix.Repo.Migrations.AddProductsNameUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:products, [:name])
  end
end
