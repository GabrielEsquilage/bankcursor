defmodule Bankcursor.Accounts.CreateForUser do
  alias Bankcursor.Repo
  alias Bankcursor.Accounts.Account
  alias Bankcursor.Accounts.AccountNumber

  def call(user) do
    account_number = AccountNumber.generate()

    %Account{}
    |> Account.changeset(%{
      user_id: user.id,
      account_number: account_number,
      balance: 0
    })
    |> Repo.insert()
  end
end
