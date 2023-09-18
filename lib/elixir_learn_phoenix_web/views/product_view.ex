defmodule ElixirLearnPhoenixWeb.ProductView do
  use ElixirLearnPhoenixWeb, :view

  def calculate_pagination(%{
        total: total,
        page: page,
        limit: limit
      }) do
    total_page = round(Float.ceil(total / limit))

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
  end
end
