defmodule ElixirLearnPhoenix.ProductService do
  use ExUnit.Case, async: true
  import Ecto.Query, only: [from: 2]

  def list(page, limit, name, sort) do
    try do
      query =
        from(p in ElixirLearnPhoenix.Product,
          where: ilike(p.name, ^"%#{name}%"),
          order_by: [{^sort, :price}],
          limit: ^limit,
          offset: ^((page - 1) * limit)
        )

      queryTotal =
        from(p in ElixirLearnPhoenix.Product,
          where: ilike(p.name, ^"%#{name}%"),
          select: count(p.id)
        )

      result = ElixirLearnPhoenix.Repo.all(query)
      total = ElixirLearnPhoenix.Repo.one(queryTotal)

      {:ok, result, total}
    rescue
      Ecto.Query.CastError -> {:error, :resource_error}
    end
  end

  @spec detail_by_id(any) :: any
  def detail_by_id(id) do
    try do
      result = ElixirLearnPhoenix.Repo.get_by(ElixirLearnPhoenix.Product, id: id)

      case result do
        nil -> {:error, :resource_not_found}
        _ -> {:ok, result}
      end
    rescue
      Ecto.Query.CastError -> {:error, :resource_error}
    end
  end
end
