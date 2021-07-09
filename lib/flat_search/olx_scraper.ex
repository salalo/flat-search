defmodule OlxScraper do
  # use Crawly.Spider
  # alias Crawly.Utils

  # @impl Crawly.Spider
  # def base_url(), do: "https://www.olx.pl"

  # @impl Crawly.Spider
  # def init(), do: [start_urls: ["https://www.olx.pl/nieruchomosci/mieszkania/wynajem/"]]

  # @impl Crawly.Spider
  def get_links(res) do
    base = "https://www.olx.pl"
    url = HTTPotion.get(base <> "/nieruchomosci/mieszkania/wynajem")

    urls = Floki.find(url.response.body)

    urls
    |> Floki.find("tr td div table tbody tr td a.link")
    |> FLoki.attribute("href")

    IO.inspect({:ok, urls})
  end
end
