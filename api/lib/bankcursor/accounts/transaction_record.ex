defmodule Bankcursor.Accounts.TransactionRecord do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bankcursor.Accounts.Account

  @required_params [:type, :value, :account_id]
  @optional_params [:recipient_account_id, :status]

  schema "transactions" do
    field :type, Ecto.Enum, values: [:deposit, :withdraw, :transfer]
    field :value, :decimal

    field :status, Ecto.Enum,
      values: [:pending, :processing, :completed, :failed],
      default: :pending

    field :validation_digest, :binary
    # Added field
    field :error_reason, :string

    belongs_to :account, Account
    belongs_to :recipient_account, Account, foreign_key: :recipient_account_id

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    # Added :error_reason
    |> cast(attrs, @required_params ++ @optional_params ++ [:validation_digest, :error_reason])
    |> validate_required(@required_params)
  end
end
