defmodule ElixirLearnPhoenix.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :price, :integer
    field :sold, :integer
    field :rating, :string
    field :thumbnail_url, :string

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :thumbnail_url, :price, :selled, :rating])
    |> validate_required([:name, :thumbnail_url, :price, :selled, :rating])
    |> unique_constraint(:name)
  end
end
