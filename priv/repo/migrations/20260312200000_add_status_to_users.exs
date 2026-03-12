defmodule Bankcursor.Repo.Migrations.AddStatusToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :status, :string, default: "PENDING", null: false
    end
  end
end
