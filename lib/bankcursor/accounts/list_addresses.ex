defmodule Bankcursor.Accounts.ListAddresses do
  alias Bankcursor.Repo
  alias Bankcursor.Users.User

  def call(%User{} = user) do
    user
    |> Ecto.assoc(:addresses)
    |> Repo.all()
  end
end
