defmodule Bankcursor.Repo.Migrations.AddErrorReasonToTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      # Using string to be more flexible with error messages
      add :error_reason, :string
    end
  end
end
