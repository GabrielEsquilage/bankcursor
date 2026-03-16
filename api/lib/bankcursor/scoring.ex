defmodule Bankcursor.Scoring do
  alias Bankcursor.Repo
  alias Bankcursor.Scoring.ScoreEvent
  alias Bankcursor.Accounts.TransactionRecord
  alias Bankcursor.Users.User
  import Ecto.Query

  @doc """
  Calculates and awards points for a completed transaction.
  """
  def award_for_transaction(%TransactionRecord{} = transaction) do
    transaction = Repo.preload(transaction, :account)
    points = calculate_points(transaction)

    if points > 0 do
      params = %{
        user_id: transaction.account.user_id,
        points: points,
        related_transaction_id: transaction.id
      }

      create_score_event(params)
    end
  end

  @doc """
  Gets the total score for a given user.
  """
  def get_user_score(%User{} = user) do
    query =
      from s in ScoreEvent,
        where: s.user_id == ^user.id,
        select: sum(s.points)

    Repo.one(query) || 0
  end

  @doc """
  Creates a score event.
  """
  def create_score_event(attrs) do
    %ScoreEvent{}
    |> ScoreEvent.changeset(attrs)
    |> Repo.insert()
  end

  # private functions

  defp calculate_points(%TransactionRecord{type: :deposit, value: value}) do
    # 1 point for every $10 deposited
    value
    |> Decimal.div(10)
    |> Decimal.round(0, :floor)
    |> Decimal.to_integer()
  end

  defp calculate_points(%TransactionRecord{type: :transfer, value: value}) do
    # 1 point for every $20 transferred
    value
    |> Decimal.div(20)
    |> Decimal.round(0, :floor)
    |> Decimal.to_integer()
  end

  defp calculate_points(%TransactionRecord{type: :withdraw}) do
    # No points for withdrawal
    0
  end
end
