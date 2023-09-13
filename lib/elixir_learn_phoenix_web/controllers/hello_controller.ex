defmodule ElixirLearnPhoenixWeb.HelloController do
  use ElixirLearnPhoenixWeb, :controller

  def index(conn, _params) do
    render(conn, "hello.html")
  end

  def show(conn, %{"messenger" => messenger} = _params) do
    render(conn, "show.html", messenger: messenger)
  end
end
