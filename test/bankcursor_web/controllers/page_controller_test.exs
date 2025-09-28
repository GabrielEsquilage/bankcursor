defmodule BankcursorWeb.PageControllerTest do
  use BankcursorWeb.ConnCase

  test "GET /api", %{conn: conn} do
    conn = get(conn, ~p"/api")
    assert json_response(conn, 200) == %{"message" => "bem vindo ao bankcursor"}
  end
end
