defmodule Bankcursor.Accounts.TransactionRecord do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bankcursor.Accounts.Account

  @required_params [:type, :value, :account_id]

  schema "transactions" do
    field :type, Ecto.Enum, values: [:deposit, :withdraw, :transfer]
    field :value, :decimal

    belongs_to :account, Account
    belongs_to :recipient_account, Account, foreign_key: :recipient_account_id

    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params ++ [:recipient_account_id])
    |> validate_required(@required_params)
  end
end
