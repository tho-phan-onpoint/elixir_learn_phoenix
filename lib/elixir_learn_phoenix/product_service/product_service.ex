defmodule ElixirLearnPhoenix.ProductService do
  use ExUnit.Case, async: true
  import Ecto.Query, only: [from: 2]

  def list(params) do
    name = params |> Dict.get("name", "") |> String.trim()
    sort = params |> Dict.get("sort", "asc")

    page =
      params
      |> Map.get("page", "1")
      |> Integer.parse()
      |> case do
        {value, ""} -> value
        _ -> 1
      end

    limit =
      params
      |> Map.get("page_size", "10")
      |> Integer.parse()
      |> case do
        {value, ""} -> value
        _ -> 10
      end

    sort =  String.to_atom(sort)

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

    products = ElixirLearnPhoenix.Repo.all(query)
    total = ElixirLearnPhoenix.Repo.one(queryTotal)

    {products, total, page, limit, name, sort}
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
