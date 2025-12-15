defmodule Bankcursor.Accounts.Transfer do
  alias Bankcursor.Accounts.Account
  alias Bankcursor.Accounts.TransactionRecord
  alias Bankcursor.Repo
  alias Bankcursor.Accounts.TransactionDigester
  alias Bankcursor.Users.User

  def call(%{
        "from_account_id" => from_account_id,
        "to_account_id" => to_account_id,
        "value" => value
      }) do
    with %Account{user_id: user_id} = from_account <- Repo.get(Account, from_account_id),
         %User{} = user <- Repo.get(User, user_id),
         %Account{} = to_account <- Repo.get(Account, to_account_id),
         {:ok, cast_value} <- Decimal.cast(value) do
      cond do
        from_account.id == to_account.id ->
          {:error, :same_account_transfer}

        from_account.balance < cast_value ->
          {:error, :insufficient_funds}

        true ->
          transaction_params = %{
            type: :transfer,
            value: cast_value,
            account_id: from_account_id,
            recipient_account_id: to_account_id,
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
      nil -> {:error, :account_not_found}
      :error -> {:error, :invalid_value}
      _ -> {:error, "failed to retrieve user or accounts"}
    end
  end

  def call(_), do: {:error, "invalid params"}
end
