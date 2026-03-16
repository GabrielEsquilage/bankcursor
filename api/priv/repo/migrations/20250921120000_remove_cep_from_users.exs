defmodule Bankcursor.Repo.Migrations.RemoveCepFromUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :cep
    end
  end
end
