defmodule Bankcursor.Accounts.Withdraw do
  alias Bankcursor.Accounts.Account
  alias Bankcursor.Accounts.TransactionRecord
  alias Bankcursor.Repo

  def call(%{"account_id" => account_id, "value" => value}) do
    with %Account{} = account <- Repo.get(Account, account_id),
         {:ok, cast_value} <- Decimal.cast(value) do
      if cast_value > account.balance do
        {:error, :insufficient_funds}
      else
        params = %{
          type: :withdraw,
          value: cast_value,
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
      end
    else
      nil -> {:error, :account_not_found}
      :error -> {:error, :invalid_value}
    end
  end

  def call(_), do: {:error, "invalid params"}
end
