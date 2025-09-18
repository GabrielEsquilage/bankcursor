defmodule Bankcursor.Accounts.DeleteAddress do
  alias Bankcursor.Repo
  alias Bankcursor.Accounts.Address

  def call(%Address{} = address) do
    Repo.delete(address)
  end
end
