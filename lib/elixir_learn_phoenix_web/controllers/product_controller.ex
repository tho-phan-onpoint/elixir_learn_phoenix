defmodule ElixirLearnPhoenixWeb.ProductController do
  use ElixirLearnPhoenixWeb, :controller

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, params) do
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

    page_size =
      params
      |> Map.get("page_size", "10")
      |> Integer.parse()
      |> case do
        {value, ""} -> value
        _ -> 10
      end

    {status, products, total} =
      ElixirLearnPhoenix.ProductService.list(page, page_size, name, String.to_atom(sort))

    total_page = round(Float.ceil(total / page_size))

    pagination =
      case total_page <= 0 do
        true ->
          []

        false ->
          Enum.reduce(1..total_page, [], fn p, acc ->
            if abs(p - page) <= 2 or p in [1, total_page] do
              acc ++ [p]
            else
              acc ++ ["..."]
            end
          end)
          |> Enum.dedup()
      end

    case status do
      :ok ->
        render(conn, "index.html",
          status: status,
          data: products,
          page: page,
          page_size: page_size,
          total_page: total_page,
          pagination: pagination,
          name: name,
          sort: sort
        )

      :error ->
        render(conn, "index.html",
          status: :not_found,
          data: nil,
          page: page,
          page_size: page_size,
          total_page: total_page,
          pagination: pagination,
          name: name,
          sort: sort
        )
    end
  end

  def detail(conn, %{"id" => id}) when not is_nil(id) do
    {status, p} = ElixirLearnPhoenix.ProductService.detail_by_id(id)

    case status do
      :ok -> render(conn, "detail.html", status: status, data: p)
      :error -> render(conn, "detail.html", status: :not_found, data: nil)
    end
  end
end
