defmodule Bankcursor.Accounts.AccountSupervisor do
  use DynamicSupervisor

  alias Bankcursor.Accounts.AccountWorker

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_worker(account_id) do
    spec = {AccountWorker, [account_id: account_id]}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
