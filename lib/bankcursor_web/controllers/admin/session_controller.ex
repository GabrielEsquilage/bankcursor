defmodule BankcursorWeb.Admin.SessionController do
  use BankcursorWeb, :controller

  alias BankcursorWeb.Token

  def create(conn, %{"token" => token}) do
    case Token.verify(token) do
      {:ok, %{user_id: user_id}} ->
        conn
        |> put_session(:user_id, user_id)
        |> put_flash(:info, "Bem-vindo ao Painel Administrativo.")
        |> redirect(to: ~p"/admin")

      {:ok, user_id} when is_integer(user_id) ->
        conn
        |> put_session(:user_id, user_id)
        |> put_flash(:info, "Bem-vindo ao Painel Administrativo.")
        |> redirect(to: ~p"/admin")

      {:error, _} ->
        conn
        |> put_flash(:error, "Sessão inválida.")
        |> redirect(to: ~p"/admin/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: ~p"/admin/login")
  end
end
