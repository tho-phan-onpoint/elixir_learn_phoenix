defmodule ElixirLearnPhoenixWeb.CrawlerService do
  use ElixirLearnPhoenixWeb, :controller
  use ExUnit.Case, async: true
  use Hound.Helpers
  import Ecto.Query, warn: false

  def save_product_to_db(url) do
    Hound.start_session()
    navigate_to(url)

    selectorProductListParent = ".product-list-cat"
    selectorProductItem = ".product-item"
    selectorProductItemName = ".product-name"
    selectorProductItemThumbnailUrl = ".product-img a.thumb-img img"
    selectorProductItemPrice = ".product-price"
    selectorProductItemRating = "input[type=hidden]"
    selectorProductItemSold = ".selled"

    page_html = page_source()

    {:ok, document} = Floki.parse_document(page_html)

    document
    |> Floki.find(selectorProductListParent)
    |> Floki.find(selectorProductItem)
    |> Enum.each(fn child_element ->
      name = parse_name(child_element, selectorProductItemName)
      thumbnail_url = parse_thumbnail_url(child_element, selectorProductItemThumbnailUrl, "src")
      price = parse_price(child_element, selectorProductItemPrice)
      sold = parse_sold(child_element, selectorProductItemSold)
      rating = parse_rating(child_element, selectorProductItemRating, "value")

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

      IO.inspect(product, label: "product")
    end)

    IO.inspect("done", label: "done")
  end

  def get_string(child_element, selector) do
    child_element
    |> Floki.find(selector)
    |> Floki.text()
    |> String.trim()
  end

  def get_attr(child_element, selector, attr) do
    child_element
    |> Floki.find(selector)
    |> Floki.attribute(attr)
    |> Floki.text()
    |> String.trim()
  end

  def parse_name(child_element, selector) do
    get_string(child_element, selector)
  end

  def parse_thumbnail_url(child_element, selector, attr) do
    get_attr(child_element, selector, attr)
  end

  def parse_price(child_element, selector) do
    get_string(child_element, selector)
    |> String.slice(0..-2)
    |> String.replace(".", "")
    |> Integer.parse()
    |> case do
      {value, ""} -> value
      _ -> 0
    end
  end

  def parse_rating(child_element, selector, attr) do
    get_attr(child_element, selector, attr)
    |> Floki.text()
    |> String.trim()
    |> Float.parse()
    |> case do
      {value, ""} -> value
      _ -> 0.0
    end
  end

  def parse_sold(child_element, selector) do
    pattern = ~r/\d+/
    input_string = get_string(child_element, selector)

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
