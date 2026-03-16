defmodule Bankcursor.Scoring.ScoreEvent do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bankcursor.Users.User
  alias Bankcursor.Accounts.TransactionRecord

  @required_params [:user_id, :points, :related_transaction_id]

  schema "score_events" do
    field :points, :integer

    belongs_to :user, User
    belongs_to :related_transaction, TransactionRecord, foreign_key: :related_transaction_id

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
  end
end
