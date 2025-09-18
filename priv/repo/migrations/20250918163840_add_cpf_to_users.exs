defmodule Bankcursor.Repo.Migrations.AddCpfToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :cpf, :string
    end
    create unique_index(:users, [:cpf])
  end
end
