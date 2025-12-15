defmodule Bankcursor.Scoring.ScoringRouter do
  use GenServer

  alias Bankcursor.Repo
  alias Bankcursor.Scoring

  # Client API
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    Phoenix.PubSub.subscribe(Bankcursor.PubSub, "scoring")
    {:ok, %{}}
  end

  @impl true
  def handle_info({:transaction_completed, transaction}, state) do
    # The transaction from the AccountWorker might not have associations loaded.
    # Preload the account and user to ensure the Scoring context has the data it needs.
    reloaded_tx =
      transaction
      |> Repo.preload([account: :user])

    Scoring.award_for_transaction(reloaded_tx)

    {:noreply, state}
  end
end
