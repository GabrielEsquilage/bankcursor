defmodule BankcursorWeb.Plugs.AdminAuth do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]

    if user && user.role in ["admin", "collaborator"] do
      conn
    else
      conn
      |> put_flash(:error, "Acesso restrito.")
      |> redirect(to: "/admin/login")
      |> halt()
    end
  end
end
