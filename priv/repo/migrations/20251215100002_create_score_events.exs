defmodule Bankcursor.Repo.Migrations.CreateScoreEvents do
  use Ecto.Migration

  def change do
    create table(:score_events) do
      add :points, :integer, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :related_transaction_id, references(:transactions, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:score_events, [:user_id])
    create index(:score_events, [:related_transaction_id])
  end
end
