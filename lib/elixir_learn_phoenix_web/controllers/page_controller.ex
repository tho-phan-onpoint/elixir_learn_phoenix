defmodule ElixirLearnPhoenixWeb.PageController do
  use ElixirLearnPhoenixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
