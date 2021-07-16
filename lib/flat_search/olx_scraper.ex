defmodule FlatSearch.OlxScraper do
  alias FlatSearch.Flats

  @base_url "https://www.olx.pl"
  @url "https://www.olx.pl/nieruchomosci/mieszkania/wynajem/"

  def run do
    Crawly.fetch(@url).body
    |> Floki.parse_document()
    |> case do
      {:ok, document} -> document
      _ -> nil
    end
    |> get_range_of_pages()
    |> Enum.each(&Task.async(fn -> get_flats("#{@url}?page=#{&1}") end))
  end

  defp get_flats(url) do
    Crawly.fetch(url).body
    |> Floki.parse_document()
    |> case do
      {:ok, document} -> document
      _ -> nil
    end
    |> Floki.find("tr td div table tbody tr td a.link")
    |> Floki.attribute("href")
    |> Enum.filter(&String.contains?(&1, @base_url))
    |> Enum.uniq()
    |> Enum.map(&parse_flat(&1))
  end

  defp get_range_of_pages(document) do
    # Gets number of pages
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
      Crawly.fetch(url).body
      |> Floki.parse_document()
      |> case do
        {:ok, document} -> document
        _ -> nil
      end

    flat_record = %{
      price: get_price(document),
      additional_price: get_additional_price(document),
      title: get_title(document),
      # description: get_description(document),
      negotiation: negotiable?(document),
      surface: get_surface(document),
      photo_links: get_photo_links(document),
      link: url
    }

    Flats.create_flat(flat_record)
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

  defp get_nested_element(enum) do
    enum
    |> Enum.at(0)
    |> elem(2)
    |> Enum.at(0)
  end
end
