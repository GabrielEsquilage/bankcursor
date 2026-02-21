defmodule Bankcursor.Repo.Migrations.CreateStaffMembers do
  use Ecto.Migration

  def change do
    create table(:staff_members) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :staff_number, :string, null: false
      add :role, :string, null: false, default: "collaborator"

      timestamps()
    end

    create unique_index(:staff_members, [:email])
    create unique_index(:staff_members, [:staff_number])
  end
end
