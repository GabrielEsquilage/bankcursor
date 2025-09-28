defmodule Bankcursor.Repo.Migrations.AddAccountNumberToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :account_number, :string, null: false
    end

    create index(:accounts, [:account_number], unique: true)
  end
end
