defmodule Bankcursor.Accounts.Deposit do
  alias Bankcursor.Accounts.Account
  alias Bankcursor.Accounts.TransactionRecord
  alias Bankcursor.Repo
  alias Ecto.Multi

  def call(%{"account_id" => account_id, "value" => value}) do
    with %Account{} = account <- Repo.get(Account, account_id),
         {:ok, value} <- Decimal.cast(value) do
      Multi.new()
      |> deposit(account, value)
      |> record_transaction(account, value)
      |> Repo.transaction()
      |> handle_transaction()
    else
      nil -> {:error, :not_found}
      :error -> {:error, "Invalid Value"}
    end
  end

  def call(_), do: {:error, "invalid params"}

  defp deposit(multi, from_account, value) do
    new_balance = Decimal.add(from_account.balance, value)
    changeset = Account.changeset(from_account, %{balance: new_balance})
    Multi.update(multi, :deposit, changeset)
  end

  defp record_transaction(multi, account, value) do
    params = %{
      type: :deposit,
      value: value,
      account_id: account.id
    }

    Multi.insert(multi, :record, TransactionRecord.changeset(params))
  end

  defp handle_transaction({:ok, %{deposit: account}}), do: {:ok, account}
  defp handle_transaction({:error, _op, reason, _}), do: {:error, reason}
end
