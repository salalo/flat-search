defmodule FlatSearch.Filters do
  @moduledoc """
  The filters context
  """

  alias FlatSearch.Filters.Filter

  def change_filter(%Filter{} = filter, params \\ %{}), do: Filter.changeset(filter, params)
end
