defmodule BankcursorWeb.Plugs.Auth do

  import Plug.Conn

  alias BankcursorWeb.Token

  def init(opts), do: opts

  def call(conn, _opts) do
    authorization_header = Plug.Conn.get_req_header(conn, "authorization")
    IO.inspect(authorization_header, label: "Authorization Header")

    with ["Bearer " <> token]  <- authorization_header,
          {:ok, %{user_id: user_id}} <- (IO.inspect(Token.verify(token), label: "Token Verification Result")) do
      assign(conn, :user_id, user_id)
    else
      _error ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.put_view(json: BankcursorWeb.ErrorJSON)
        |> Phoenix.Controller.render(:error, status: :unauthorized)
        |> halt()
    end
  end
end
