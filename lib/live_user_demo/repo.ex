defmodule LiveUserDemo.Repo do
  use Ecto.Repo,
    otp_app: :live_user_demo,
    adapter: Ecto.Adapters.Postgres
end
