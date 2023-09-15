defmodule ElixirLearnPhoenixWeb.CrawlerService do
  use ElixirLearnPhoenixWeb, :controller
  use ExUnit.Case, async: true
  use Hound.Helpers
  import Ecto.Query, warn: false

  def save_product_to_db(url) do
    Hound.start_session()
    navigate_to(url)

    config = %{
      selector_product_list_parent: ".product-list-cat",
      selector_product_item: ".product-item",
      selector_product_item_name: ".product-name",
      selector_product_item_thumbnail_url: ".product-img a.thumb-img img",
      selector_product_item_thumbnail_url_attr: "src",
      selector_product_item_price: ".product-price",
      selector_product_item_rating: "input[type=hidden]",
      selector_product_item_rating_attr: "value",
      selector_product_item_sold: ".selled"
    }

    page_html = page_source()

    {:ok, document} = Floki.parse_document(page_html)

    document
    |> Floki.find(config[:selector_product_list_parent])
    |> Floki.find(config[:selector_product_item])
    |> Enum.each(fn child_element ->
      name = parse_name(child_element, config)
      thumbnail_url = parse_thumbnail_url(child_element, config)
      price = parse_price(child_element, config)
      sold = parse_sold(child_element, config)
      rating = parse_rating(child_element, config)

      product = %ElixirLearnPhoenix.Product{
        name: name,
        thumbnail_url: thumbnail_url,
        price: price,
        rating: rating,
        sold: sold
      }

      existing_product = ElixirLearnPhoenix.Repo.get_by(ElixirLearnPhoenix.Product, name: name)

      case existing_product do
        nil ->
          ElixirLearnPhoenix.Repo.insert(product)
        _ ->
          existing_product
          |> Ecto.Changeset.change(%{
            thumbnail_url: thumbnail_url,
            price: price,
            rating: rating,
            sold: sold
          })
          |> ElixirLearnPhoenix.Repo.update()
      end
    end)
  end

  defp get_string(child_element, selector) do
    child_element
    |> Floki.find(selector)
    |> Floki.text()
    |> String.trim()
  end

  defp get_attr(child_element, selector, attr) do
    child_element
    |> Floki.find(selector)
    |> Floki.attribute(attr)
    |> Floki.text()
    |> String.trim()
  end

  defp parse_name(child_element, config) do
    get_string(child_element, config[:selector_product_item_name])
  end

  defp parse_thumbnail_url(child_element, config) do
    get_attr(child_element, config[:selector_product_item_thumbnail_url], config[:selector_product_item_thumbnail_url_attr])
  end

  defp parse_price(child_element, config) do
    get_string(child_element, config[:selector_product_item_price])
    |> String.slice(0..-2)
    |> String.replace(".", "")
    |> Integer.parse()
    |> case do
      {value, ""} -> value
      _ -> 0
    end
  end

  defp parse_rating(child_element, config) do
    get_attr(child_element, config[:selector_product_item_rating], config[:selector_product_item_rating_attr])
    |> Floki.text()
    |> String.trim()
    |> Float.parse()
    |> case do
      {value, ""} -> value
      _ -> 0.0
    end
  end

  defp parse_sold(child_element, config) do
    pattern = ~r/\d+/
    input_string = get_string(child_element, config[:selector_product_item_sold])

    Regex.run(pattern, input_string)
    |> Floki.text()
    |> Integer.parse()
    |> case do
      {value, ""} -> value
      _ -> 0
    end
    |> Kernel.*(1000)
  end
end
