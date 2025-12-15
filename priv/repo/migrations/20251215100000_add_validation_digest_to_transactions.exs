defmodule Bankcursor.Repo.Migrations.AddValidationDigestToTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :validation_digest, :binary
    end
  end
end
