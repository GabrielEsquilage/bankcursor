defmodule Bankcursor.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :street, :string, null: false
      add :number, :string
      add :complement, :string
      add :neighborhood, :string, null: false
      add :city, :string, null: false
      add :state, :string, null: false
      add :zip_code, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:addresses, [:user_id])
  end
end
