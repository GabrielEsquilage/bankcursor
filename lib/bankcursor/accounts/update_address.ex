defmodule Bankcursor.Accounts.UpdateAddress do
  alias Bankcursor.Repo
  alias Bankcursor.Accounts.Address

  def call(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end
end
