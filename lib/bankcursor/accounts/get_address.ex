defmodule Bankcursor.Accounts.GetAddress do
  alias Bankcursor.Repo
  alias Bankcursor.Users.User
  alias Bankcursor.Accounts.Address

  def call(%User{} = user, id) do
    case Repo.get_by(Address, user_id: user.id, id: id) do
      nil -> {:error, :not_found}
      address -> {:ok, address}
    end
  end
end
