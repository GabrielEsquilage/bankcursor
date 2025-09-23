defmodule Bankcursor.Accounts.TransactionRouter do
  use GenServer

  alias Bankcursor.Accounts.AccountSupervisor
  alias Bankcursor.Accounts.AccountWorker

  # Client API
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # GenServer callbacks
  @impl true
  def init(_opts) do
    Phoenix.PubSub.subscribe(Bankcursor.PubSub, "transactions")
    {:ok, %{}}
  end

  @impl true
  def handle_info({:new_transaction, transaction}, state) do
    AccountSupervisor.start_worker(transaction.account_id)

    AccountWorker.process(transaction)

    {:noreply, state}
  end
end
