defmodule Bankcursor.Accounts.Deposit do
  alias Bankcursor.Accounts.Account
  alias Bankcursor.Accounts.TransactionRecord
  alias Bankcursor.Repo
  alias Bankcursor.Accounts.TransactionDigester
  alias Bankcursor.Users.User

  def call(%{"account_id" => account_id, "value" => value}) do
    with %Account{user_id: user_id} = account <- Repo.get(Account, account_id),
         %User{} = user <- Repo.get(User, user_id),
         {:ok, _value} <- Decimal.cast(value) do
      transaction_params = %{
        type: :deposit,
        value: value,
        account_id: account_id,
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
    else
      nil -> {:error, :account_not_found}
      :error -> {:error, :invalid_value}
      _ -> {:error, "failed to retrieve user or account"}
    end
  end

  def call(_), do: {:error, "invalid params"}
end
