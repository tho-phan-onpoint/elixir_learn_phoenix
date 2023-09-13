defmodule ElixirLearnPhoenixWeb.PageTest do
  use ExUnit.Case, async: true
  use Hound.Helpers

  setup do
    :ok = Application.ensure_all_started(:elixir_learn_phoenix)
    Hound.start_session()
    navigate_to("/path/to/your/page")
    {:ok, []}
  end

  test "get HTML content of a page with JavaScript" do
    # You can interact with the page here if needed

    # Get the HTML content of the page
    page_html = page_source()

    # Perform assertions on the HTML content
    assert String.contains?(page_html, "Expected Text")
  end

  defp teardown(_context) do
    Hound.end_session()
    :ok
  end
end
