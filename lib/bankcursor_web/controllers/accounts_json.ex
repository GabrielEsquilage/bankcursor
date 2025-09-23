defmodule BankcursorWeb.AccountsJSON do
  alias Bankcursor.Accounts.Account

  def create(%{account: account}) do
    %{
      message: "Conta criado com sucesso",
      data: data(account)
    }
  end

  def deposit(%{account: account}) do
    %{
      message: "Deposito realizado com sucesso",
      data: data(account)
    }
  end

  def withdraw(%{account: account}) do
    %{
      message: "Saque realizado com sucesso",
      data: data(account)
    }
  end

  def transfer(%{transaction_record: transaction_record}) do
    %{
      message: "Transfer request accepted. It will be processed shortly.",
      data: transaction_data(transaction_record)
    }
  end

  defp transaction_data(transaction_record) do
    %{
      id: transaction_record.id,
      type: transaction_record.type,
      value: transaction_record.value,
      status: transaction_record.status,
      from_account_id: transaction_record.account_id,
      to_account_id: transaction_record.recipient_account_id,
      inserted_at: transaction_record.inserted_at
    }
  end

  defp data(%Account{} = account) do
    %{
      id: account.id,
      balance: account.balance,
      user_id: account.user_id
    }
  end
end
