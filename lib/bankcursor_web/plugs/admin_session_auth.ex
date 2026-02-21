defmodule BankcursorWeb.Plugs.AdminSessionAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias Bankcursor.Repo
  alias Bankcursor.Staff.StaffMember

  def init(opts), do: opts

  def call(conn, _opts) do
    user_session = get_session(conn, :user_id)
    
    user_id = case user_session do
      %{user_id: id} -> id
      id when is_integer(id) -> id
      _ -> nil
    end

    if user_id do
      case Repo.get(StaffMember, user_id) do
        nil ->
          conn
          |> put_flash(:error, "Sessão inválida.")
          |> redirect(to: "/admin/login")
          |> halt()
        user ->
          assign(conn, :current_user, user)
      end
    else
      conn
      |> redirect(to: "/admin/login")
      |> halt()
    end
  end
end
