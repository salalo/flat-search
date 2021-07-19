defmodule FlatSearch.Filters do
  @moduledoc """
  The filters context
  """

  alias FlatSearch.Filters.Filter

  def change_filter(%Filter{} = filter), do: Filter.changeset(filter, %{})
  def change_filter(%Filter{} = filter, _), do: Filter.changeset(filter, %{})
end
