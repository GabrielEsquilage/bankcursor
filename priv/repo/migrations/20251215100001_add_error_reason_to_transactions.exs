defmodule Bankcursor.Repo.Migrations.AddErrorReasonToTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :error_reason, :string # Using string to be more flexible with error messages
    end
  end
end
