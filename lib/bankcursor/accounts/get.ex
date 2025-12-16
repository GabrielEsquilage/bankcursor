defmodule Bankcursor.Accounts.Get do
  alias Bankcursor.Repo
  alias Bankcursor.Accounts.Account
  alias Bankcursor.Accounts.TransactionRecord

  def call_by_account_number(account_number) do
    case Repo.get_by(Account, account_number: account_number) do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  def call_by_id(transaction_id) do
    case Repo.get(TransactionRecord, transaction_id) do
      nil -> {:error, :not_found}
      transaction -> {:ok, transaction}
    end
  end
end
