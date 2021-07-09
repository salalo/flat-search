defmodule FlatSearch.Repo do
  use Ecto.Repo,
    otp_app: :flat_search,
    adapter: Ecto.Adapters.Postgres
end
