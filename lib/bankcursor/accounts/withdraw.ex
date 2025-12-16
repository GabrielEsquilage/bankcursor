defmodule Bankcursor.Accounts.Withdraw do
  alias Bankcursor.Accounts
  alias Bankcursor.Accounts.TransactionRecord
  alias Bankcursor.Repo
  alias Bankcursor.Accounts.TransactionDigester
  alias Bankcursor.Users.User

  def call(%{"account_number" => account_number, "value" => value}) do
    with {:ok, fetched_account} <- Accounts.get_by_account_number(account_number),
         %User{} = user <- Repo.get(User, fetched_account.user_id),
         {:ok, cast_value} <- Decimal.cast(value) do
      if cast_value > fetched_account.balance do
        {:error, :insufficient_funds}
      else
        transaction_params = %{
          type: :withdraw,
          value: cast_value,
          account_id: fetched_account.id,
          status: :pending
        }

        temp_transaction_record =
          %TransactionRecord{}
          |> TransactionRecord.changeset(transaction_params)
          |> Ecto.Changeset.apply_changes()
          |> Map.put(:inserted_at, DateTime.utc_now())

        validation_digest = TransactionDigester.generate(user, temp_transaction_record)

        final_params = Map.put(transaction_params, :validation_digest, validation_digest)

        case Repo.insert(TransactionRecord.changeset(%TransactionRecord{}, final_params)) do
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
      {:error, :not_found} -> {:error, :account_not_found}
      :error -> {:error, :invalid_value}
      _ -> {:error, "failed to retrieve user or account"}
    end
  end

  def call(_), do: {:error, "invalid params"}
end
