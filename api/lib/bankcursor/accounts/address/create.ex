defmodule Bankcursor.Accounts.Address.Create do
  alias Bankcursor.Repo
  alias Bankcursor.Users.User
  alias Bankcursor.Accounts.Address

  def call(%User{} = user, address_params) do
    user
    |> Ecto.build_assoc(:addresses)
    |> Address.changeset(address_params)
    |> Repo.insert()
  end
end
