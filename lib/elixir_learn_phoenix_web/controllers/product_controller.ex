defmodule ElixirLearnPhoenixWeb.ProductController do
  use ElixirLearnPhoenixWeb, :controller

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, params) do
    {products, total, page, limit, name, sort} = ElixirLearnPhoenix.ProductService.list(params)

    render(conn, "index.html",
        products: products,
        total: total,
        page: page,
        page_size: limit,
        name: name,
        sort: sort
    )
  end

  @index_params_schema  %{
    id: [type: :integer, number: [greater_than: 0]],
  }
  def detail(conn, params) do
    with {:ok, better_params} <- Tarams.cast(params, @index_params_schema) do
      {status, product} = ElixirLearnPhoenix.ProductService.detail_by_id(better_params[:id])
        render(conn, "detail.html", status: status, data: product)
    else
        {:error, _errors} -> render(conn, "detail.html", status: :not_found, data: nil)
    end
  end
end
