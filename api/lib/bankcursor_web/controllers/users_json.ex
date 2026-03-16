defmodule BankcursorWeb.UsersJSON do
  alias Bankcursor.Users.User
  alias Bankcursor.Accounts.Account

  def render("create.json", %{user: user, account: account}) do
    create(%{user: user, account: account})
  end

  def render("login.json", _assigns) do
    login(%{message: "Usuario Autenticado com Sucesso"})
  end

  def render("get.json", %{user: user}) do
    get(%{user: user})
  end

  def render("delete.json", %{user: user}) do
    delete(%{user: user})
  end

  def render("update.json", %{user: user}) do
    update(%{user: user})
  end

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

  def update(%{user: user}),
    do: %{message: "User Atualizado com Sucesso!", data: data(user, user.account)}

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
