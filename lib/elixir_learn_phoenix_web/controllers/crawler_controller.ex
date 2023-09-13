defmodule ElixirLearnPhoenixWeb.CrawlerController do
  use ElixirLearnPhoenixWeb, :controller

  def index(conn, _params) do
    render(conn, "crawler.html")
  end

  def crawl(conn, params) do
    # TODO valid input
    ElixirLearnPhoenixWeb.CrawlerService.save_product_to_db(params["urlInput"])
    redirect(conn, to: "/products")
  end
end
