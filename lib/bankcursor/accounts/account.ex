defmodule Bankcursor.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bankcursor.Users.User

  @required_params [:balance, :user_id, :account_number]

  schema "accounts" do
    field :balance, :decimal
    field :account_number, :string
    belongs_to :user, User

    timestamps()
  end

  def changeset(account \\ %__MODULE__{}, params) do
    account
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> check_constraint(:balance, name: :balance_must_be_positive)
    |> unique_constraint(:user_id, name: :accounts_user_id_unique)
    |> unique_constraint(:account_number, name: :accounts_account_number_index)
  end
end
