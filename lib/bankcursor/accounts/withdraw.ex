defmodule Bankcursor.Accounts.Withdraw do
  alias Bankcursor.Accounts.Account
  alias Bankcursor.Accounts.TransactionRecord
  alias Bankcursor.Repo
  alias Ecto.Multi

  def call(%{"account_id" => account_id, "value" => value}) do
    with %Account{} = account <- Repo.get(Account, account_id),
         {:ok, value} <- Decimal.cast(value) do
      if value > account.balance do
        {:error, :insufficient_funds}
      else
        Multi.new()
        |> withdraw(account, value)
        |> record_transaction(account, value)
        |> Repo.transaction()
        |> handle_transaction()
      end
    else
      nil -> {:error, :not_found}
      :error -> {:error, "Invalid Value"}
    end
  end

  def call(_), do: {:error, "invalid params"}

  defp withdraw(multi, to_account, value) do
    new_balance = Decimal.sub(to_account.balance, value)
    changeset = Account.changeset(to_account, %{balance: new_balance})
    Multi.update(multi, :withdraw, changeset)
  end

  defp record_transaction(multi, account, value) do
    params = %{
      type: :withdraw,
      value: value,
      account_id: account.id
    }

    Multi.insert(multi, :record, TransactionRecord.changeset(params))
  end

  defp handle_transaction({:ok, %{withdraw: account}}), do: {:ok, account}
  defp handle_transaction({:error, _op, reason, _}), do: {:error, reason}
end
