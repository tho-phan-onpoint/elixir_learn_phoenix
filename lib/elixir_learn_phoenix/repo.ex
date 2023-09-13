defmodule ElixirLearnPhoenix.Repo do
  use Ecto.Repo,
    otp_app: :elixir_learn_phoenix,
    adapter: Ecto.Adapters.Postgres
end
