defmodule BankcursorWeb.UsersJSON do
  alias Bankcursor.Users.User

  def create(%{user: user}) do
    %{
      message: "User criado com sucesso",
      data: data(user)
    }
  end

  def login(_assigns) do
    %{
      message: "Usuario Autenticado com Sucesso"
    }
  end

  def get(%{user: user}), do: %{data: data(user)}
  def delete(%{user: user}), do: %{data: data(user)}

  def update(%{user: user}), do: %{message: "User Atualizado com Sucesso!", data: data(user)}

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      name: user.name
    }
  end
end
