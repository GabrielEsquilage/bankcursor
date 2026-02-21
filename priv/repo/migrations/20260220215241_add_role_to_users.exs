defmodule Bankcursor.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string, default: "client", null: false
    end

    create index(:users, [:role])
  end
end
