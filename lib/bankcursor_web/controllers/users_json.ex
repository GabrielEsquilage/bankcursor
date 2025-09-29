defmodule BankcursorWeb.UsersJSON do
  alias Bankcursor.Users.User
  alias Bankcursor.Accounts.Account

  def create(%{user: user, account: account}) do
    %{
      message: "User criado com sucesso",
      data: data(user, account)
    }
  end

  def login(_assigns) do
    %{
      message: "Usuario Autenticado com Sucesso"
    }
  end

  def get(%{user: user}), do: %{data: data(user, user.account)}
  def delete(%{user: user}), do: %{data: data(user, user.account)}

  def update(%{user: user}), do: %{message: "User Atualizado com Sucesso!", data: data(user, user.account)}

  defp data(%User{} = user, %Account{} = account) do
    %{
      id: user.id,
      email: user.email,
      name: user.name,
      account: %{
        account_number: account.account_number,
        balance: account.balance
      }
    }
  end
end
