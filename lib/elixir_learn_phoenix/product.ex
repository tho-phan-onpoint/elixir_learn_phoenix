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

  @default_fields [
    :id,
    :inserted_at,
    :updated_at
  ]

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, __MODULE__.__schema__(:fields) -- @default_fields)
    |> validate_required([:name, :thumbnail_url, :price, :selled, :rating])
    |> unique_constraint(:name)
  end
end
