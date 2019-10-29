defmodule Spelling.Repo do
  use Ecto.Repo,
    otp_app: :spelling,
    adapter: Ecto.Adapters.Postgres
end
