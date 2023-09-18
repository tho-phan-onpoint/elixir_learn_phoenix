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

  def detail(conn, %{"id" => id}) when not is_nil(id) do
    {status, p} = ElixirLearnPhoenix.ProductService.detail_by_id(id)

    case status do
      :ok -> render(conn, "detail.html", status: status, data: p)
      :error -> render(conn, "detail.html", status: :not_found, data: nil)
    end
  end
end
