defmodule FlatSearch.OlxScraper do
  alias FlatSearch.Flats

  @base_query_url "https://www.olx.pl"
  @query_url "https://www.olx.pl/nieruchomosci/mieszkania/wynajem/"

  def run do
    @query_url
    |> Crawly.fetch()
    |> Map.get(:body)
    |> Floki.parse_document()
    |> case do
      {:ok, document} -> document
      _ -> ""
    end
    |> get_range_of_pages()
    |> Enum.each(&Task.async(fn -> get_flats("#{@query_url}?page=#{&1}") end))
  end

  defp get_flats(url) do
    url
    |> Crawly.fetch()
    |> Map.get(:body)
    |> Floki.parse_document()
    |> case do
      {:ok, document} -> document
      _ -> ""
    end
    |> Floki.find("tr td div table tbody tr td a.link")
    |> Floki.attribute("href")
    |> Enum.filter(&String.contains?(&1, @base_query_url))
    |> Enum.uniq()
    |> Enum.map(&parse_flat(&1))
  end

  defp get_range_of_pages(document) do
    document
    |> Floki.find("[data-cy=page-link-last]")
    |> Enum.at(0)
    |> elem(2)
    |> Enum.at(0)
    |> elem(2)
    |> Enum.at(0)
    |> str_to_num()
    |> Range.new(1)
  end

  defp parse_flat(url) do
    document =
      url
      |> Crawly.fetch()
      |> Map.get(:body)
      |> Floki.parse_document()
      |> case do
        {:ok, document} -> document
        _ -> ""
      end

    flat_record = %{
      price: get_price(document),
      additional_price: get_additional_price(document),
      title: get_title(document),
      # description: get_description(document),
      negotiation: negotiable?(document),
      surface: get_surface(document),
      photo_links: get_photo_links(document),
      link: url,
      region: manage_location_data(document, 0),
      city: manage_location_data(document, 1),
      district: manage_location_data(document, 2)
    }

    Flats.create_flat(flat_record)
  end

  @spec get_localization(document :: HTML) :: [String.t() | nil, ...]
  defp get_localization(document) do
    document
    |> Floki.find("[data-testid=breadcrumb-item] a:fl-contains('Wynajem - ')")
    |> Floki.text()
    |> String.split("Wynajem - ")
    |> tl()
  end

  defp get_title(document) do
    document
    |> Floki.find("h1")
    |> get_nested_element()
  end

  defp get_price(document) do
    document
    |> Floki.find("h3, zł")
    |> get_nested_element()
    |> str_to_num()
  end

  defp get_additional_price(document) do
    document
    |> Floki.find("ul li p:fl-contains('Czynsz')")
    |> get_nested_element()
    |> String.split(": ")
    |> Enum.at(1)
    |> String.split(" zł")
    |> Enum.at(0)
    |> str_to_num()
  end

  defp negotiable?(document) do
    document
    |> Floki.find("p:fl-contains('do negocjacji')")
    |> Enum.empty?()
    |> Kernel.!()
  end

  defp get_description(document) do
    document
    |> Floki.find("[data-cy=ad_description]")
    |> Enum.at(0)
    |> elem(2)
    |> Enum.at(-1)
    |> elem(2)
  end

  defp get_surface(document) do
    document
    |> Floki.find("p:fl-contains('Powierzchnia')")
    |> get_nested_element()
    |> String.split(": ")
    |> Enum.at(1)
    |> String.split(" m")
    |> Enum.at(0)
    |> str_to_num()
  end

  defp get_photo_links(document) do
    document
    |> Floki.find(".swiper-slide .swiper-zoom-container img")
    |> Floki.attribute("data-src")
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

  defp get_nested_element(enum) when enum != [] do
    enum
    |> Enum.at(0)
    |> elem(2)
    |> Enum.at(0)
  end

  defp insensitive_string(nil), do: ""
  defp insensitive_string(""), do: ""

  defp insensitive_string(value) do
    value
    |> String.downcase()
    |> (&:iconv.convert("utf-8", "ascii//translit", &1)).()
    |> String.replace("'", "")
  end

  defp manage_location_data(document, depth),
    do: document |> get_localization() |> Enum.at(depth) |> insensitive_string()
end
