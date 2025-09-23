defmodule Bankcursor.Accounts.Transfer do
  alias Bankcursor.Accounts.Account
  alias Bankcursor.Accounts.TransactionRecord
  alias Bankcursor.Repo

  def call(%{
        "from_account_id" => from_account_id,
        "to_account_id" => to_account_id,
        "value" => value
      }) do
    with %Account{} = from_account <- Repo.get(Account, from_account_id),
         %Account{} = to_account <- Repo.get(Account, to_account_id),
         {:ok, cast_value} <- Decimal.cast(value) do
      cond do
        from_account.id == to_account.id ->
          {:error, :same_account_transfer}

        from_account.balance < cast_value ->
          {:error, :insufficient_funds}

        true ->
          params = %{
            type: :transfer,
            value: cast_value,
            account_id: from_account_id,
            recipient_account_id: to_account_id,
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
