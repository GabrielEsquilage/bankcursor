defmodule Bankcursor.Accounts.AccountWorker do
  use GenServer

  alias Bankcursor.Repo
  alias Bankcursor.Accounts.Account
  alias Bankcursor.Accounts.TransactionRecord
  alias Ecto.Multi
  alias Bankcursor.Accounts.TransactionDigester
  alias Bankcursor.Users.User

  def start_link(opts) do
    account_id = Keyword.fetch!(opts, :account_id)
    GenServer.start_link(__MODULE__, account_id, name: via_tuple(account_id))
  end

  def process(transaction) do
    account_id = transaction.account_id
    GenServer.cast(via_tuple(account_id), {:process, transaction})
  end

  defp via_tuple(account_id),
    do: {:via, Registry, {Bankcursor.Accounts.AccountRegistry, account_id}}

  @impl true
  def init(account_id) do
    {:ok, %{account_id: account_id}}
  end

  @impl true
  def handle_cast({:process, tx}, state) do
    fresh_tx = Repo.get(TransactionRecord, tx.id)

    if fresh_tx && fresh_tx.status == :pending && fresh_tx.account_id == state.account_id do
      with %Account{user_id: user_id} <- Repo.get(Account, fresh_tx.account_id),
           %User{} = user <- Repo.get(User, user_id) do
        if TransactionDigester.validate(user, fresh_tx) do
          fresh_tx
          |> TransactionRecord.changeset(%{status: :processing})
          |> Repo.update()

          execute_transaction(fresh_tx)
        else
          mark_as_failed(fresh_tx, :invalid_digest)
        end
      else
        mark_as_failed(fresh_tx, :validation_error)
      end
    end

    {:noreply, state}
  end

  defp execute_transaction(
         %TransactionRecord{type: :deposit, account_id: account_id, value: value} = tx
       ) do
    with %Account{} = account <- Repo.get(Account, account_id) do
      Multi.new()
      |> Multi.update(
        :deposit,
        Account.changeset(account, %{balance: Decimal.add(account.balance, value)})
      )
      |> Multi.update(:transaction, TransactionRecord.changeset(tx, %{status: :completed}))
      |> Repo.transaction()
      |> handle_db_transaction(tx)
    else
      _ -> mark_as_failed(tx)
    end
  end

  defp execute_transaction(
         %TransactionRecord{type: :withdraw, account_id: account_id, value: value} = tx
       ) do
    with %Account{} = account <- Repo.get(Account, account_id) do
      if account.balance < value do
        mark_as_failed(tx, :insufficient_funds)
      else
        Multi.new()
        |> Multi.update(
          :withdraw,
          Account.changeset(account, %{balance: Decimal.sub(account.balance, value)})
        )
        |> Multi.update(:transaction, TransactionRecord.changeset(tx, %{status: :completed}))
        |> Repo.transaction()
        |> handle_db_transaction(tx)
      end
    else
      _ -> mark_as_failed(tx)
    end
  end

  defp execute_transaction(
         %TransactionRecord{
           type: :transfer,
           account_id: from_id,
           recipient_account_id: to_id,
           value: value
         } = tx
       ) do
    with %Account{} = from_account <- Repo.get(Account, from_id),
         %Account{} = to_account <- Repo.get(Account, to_id) do
      if from_account.balance < value do
        mark_as_failed(tx, :insufficient_funds)
      else
        Multi.new()
        |> Multi.update(
          :withdraw,
          Account.changeset(from_account, %{balance: Decimal.sub(from_account.balance, value)})
        )
        |> Multi.update(
          :deposit,
          Account.changeset(to_account, %{balance: Decimal.add(to_account.balance, value)})
        )
        |> Multi.update(:transaction, TransactionRecord.changeset(tx, %{status: :completed}))
        |> Repo.transaction()
        |> handle_db_transaction(tx)
      end
    else
      _ -> mark_as_failed(tx)
    end
  end

  defp handle_db_transaction({:ok, _}, _tx), do: :ok

  defp handle_db_transaction({:error, _op, _reason, _changes}, tx) do
    mark_as_failed(tx, :db_error)
  end

  defp mark_as_failed(tx, reason) do
    tx
    |> TransactionRecord.changeset(%{status: :failed, error_reason: reason})
    |> Repo.update()
  end

  defp mark_as_failed(tx) do
    mark_as_failed(tx, :generic_error)
  end
end
