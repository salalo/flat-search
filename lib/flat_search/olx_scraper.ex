defmodule OlxScraper do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.olx.pl"

  @impl Crawly.Spider
  def init(), do: [start_urls: ["https://www.olx.pl/nieruchomosci/mieszkania/wynajem/"]]

  @impl Crawly.Spider
  def parse_item(res) do
    # First page only
    {:ok, document} = Floki.parse_document(res.body)

    flat_urls =
      document
      |> Floki.find("tr td div table tbody tr td a.link")
      |> Floki.attribute("href")
      |> Enum.reject(&(!String.contains?(&1, base_url())))
      |> Enum.uniq()

    Enum.map(flat_urls, &parse_flat(&1))
  end

  defp parse_flat(url) do
    res = Crawly.fetch(url)
    {:ok, document} = Floki.parse_document(res.body)

    price =
      document
      |> Floki.find("h3, zł")
      |> Enum.at(0)
      |> elem(2)
      |> Enum.at(0)
      |> str_to_num()

    additional_price =
      document
      |> Floki.find("ul li p:fl-contains('Czynsz')")
      |> Enum.at(0)
      |> elem(2)
      |> Enum.at(0)
      |> String.split(": ")
      |> Enum.at(1)
      |> String.split(" zł")
      |> Enum.at(0)
      |> str_to_num()

    title =
      document
      |> Floki.find("h1")
      |> Enum.at(0)
      |> elem(2)
      |> Enum.at(0)

    IO.inspect(price)
    # IO.inspect(title)
    IO.inspect(additional_price)
  end

  defp str_to_num(num) do
    case String.contains?(num, " ") do
      false ->
        num |> Integer.parse() |> elem(0)

      true ->
        num
        |> String.split(" ")
        |> Enum.join()
        |> Integer.parse()
        |> elem(0)
    end
  end
end
