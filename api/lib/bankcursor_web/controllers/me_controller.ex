defmodule BankcursorWeb.MeController do
  use BankcursorWeb, :controller

  alias Bankcursor.Users
  alias BankcursorWeb.UsersJSON, as: UserJSON

  def show(conn, _params) do
    user_id = conn.assigns[:user_id]

    with {:ok, user} <- Users.get(user_id) do
      user_with_account = Bankcursor.Repo.preload(user, :account)

      conn
      |> put_status(:ok)
      |> json(UserJSON.get(%{user: user_with_account}))
    end
  end
end
