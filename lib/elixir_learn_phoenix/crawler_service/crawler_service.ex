defmodule ElixirLearnPhoenixWeb.CrawlerService do
  use ElixirLearnPhoenixWeb, :controller
  use ExUnit.Case, async: true
  use Hound.Helpers
  import Ecto.Query, warn: false

  def save_product_to_db(url) do
    Hound.start_session()
    navigate_to(url)

    selector_product_list_parent= ".product-list-cat"
    selector_product_item= ".product-item"

    page_html = page_source()

    {:ok, document} = Floki.parse_document(page_html)

    document
    |> Floki.find(selector_product_list_parent)
    |> Floki.find(selector_product_item)
    |> Enum.map(fn child_element ->
        name = parse_name(child_element)
        slug = parse_slug(child_element)
        thumbnail_url = parse_thumbnail_url(child_element)
        price = parse_price(child_element)
        sold = parse_sold(child_element)
        rating = parse_rating(child_element)

        %{
          name: name,
          slug: slug,
          thumbnail_url: thumbnail_url,
          price: price,
          rating: rating,
          sold: sold
        }
      end
    )
    |> Enum.chunk_every(200)
    |> Enum.each(fn items ->
        ElixirLearnPhoenix.Repo.insert_all(
          ElixirLearnPhoenix.Product,
          items,
          on_conflict: {:replace_all_except, [:id, :slug, :inserted_at]},
          conflict_target: [:slug]
        )
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
    |> List.first()
    |> Floki.text()
    |> String.trim()
  end

  defp parse_name(child_element) do
    selector_product_item_name = ".product-item"
    get_string(child_element, selector_product_item_name)
  end

  defp parse_thumbnail_url(child_element) do
    selector_product_item_thumbnail_url= ".product-img a.thumb-img img"
      selector_product_item_thumbnail_url_attr= "src"
    get_attr(child_element, selector_product_item_thumbnail_url, selector_product_item_thumbnail_url_attr)
  end

  defp parse_price(child_element) do
    selector_product_item_price= ".product-price"
    get_string(child_element, selector_product_item_price)
    |> String.slice(0..-2)
    |> String.replace(".", "")
    |> Integer.parse()
    |> case do
      {value, ""} -> value
      _ -> 0
    end
  end

  defp parse_rating(child_element) do
    selector_product_item_rating= "input[type=hidden]"
      selector_product_item_rating_attr= "value"
    get_attr(child_element, selector_product_item_rating, selector_product_item_rating_attr)
    |> Floki.text()
    |> String.trim()
  end

  defp parse_sold(child_element) do
    selector_product_item_sold= ".selled"
    pattern = ~r/\d+/
    input_string = get_string(child_element, selector_product_item_sold)

    Regex.run(pattern, input_string)
    |> Floki.text()
    |> Integer.parse()
    |> case do
      {value, ""} -> value
      _ -> 0
    end
    |> Kernel.*(1000)
  end

  defp parse_slug(child_element) do
    selector_product_slug = ".product-item a"
    selector_product_slug_attr = "href"
    slug = get_attr(child_element, selector_product_slug, selector_product_slug_attr)
    String.replace(slug, "https://concung.com/", "")

    IO.inspect(slug, label: "slug")
  end
end
