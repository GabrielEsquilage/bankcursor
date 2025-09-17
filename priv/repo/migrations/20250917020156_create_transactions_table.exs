defmodule Bankcursor.Repo.Migrations.CreateTransactionsTable do
  use Ecto.Migration

  def up do
    execute """
    CREATE TYPE transaction_type AS ENUM ('deposit', 'withdraw', 'transfer');
    """

    create table(:transactions) do
      add :type, :transaction_type, null: false
      add :value, :decimal, null: false
      add :account_id, references(:accounts), null: false
      add :recipient_account_id, references(:accounts), null: true

      timestamps()
    end
  end

  def down do
    drop table(:transactions)
    execute """
    DROP TYPE transaction_type;
    """
  end
end