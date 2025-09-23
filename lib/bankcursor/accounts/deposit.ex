defmodule Bankcursor.Accounts.Deposit do
  alias Bankcursor.Accounts.Account
  alias Bankcursor.Accounts.TransactionRecord
  alias Bankcursor.Repo

  def call(%{"account_id" => account_id, "value" => value}) do
    with %Account{} <- Repo.get(Account, account_id),
         {:ok, _value} <- Decimal.cast(value) do
      params = %{
        type: :deposit,
        value: value,
        account_id: account_id,
        status: :pending
      }

      case Repo.insert(TransactionRecord.changeset(%TransactionRecord{}, params)) do
        {:ok, transaction_record} ->
          Phoenix.PubSub.broadcast(
            Bankcursor.PubSub,
            "transactions",
            {:new_transaction, transaction_record}
          )

          {:ok, transaction_record}

        {:error, changeset} ->
          {:error, changeset}
      end
    else
      nil -> {:error, :account_not_found}
      :error -> {:error, :invalid_value}
    end
  end

  def call(_), do: {:error, "invalid params"}
end
