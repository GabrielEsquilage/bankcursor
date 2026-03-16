defmodule Bankcursor.Repo.Migrations.AddStatusToTransactions do
  use Ecto.Migration

  def up do
    execute """
    CREATE TYPE transaction_status AS ENUM ('pending', 'processing', 'completed', 'failed');
    """

    alter table(:transactions) do
      add :status, :transaction_status, null: false, default: "pending"
    end
  end

  def down do
    alter table(:transactions) do
      remove :status
    end

    execute """
    DROP TYPE transaction_status;
    """
  end
end
