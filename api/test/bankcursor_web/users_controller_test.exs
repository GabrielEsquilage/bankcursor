defmodule BankcursorWeb.UsersControllerTest do
  use BankcursorWeb.ConnCase

  describe "create/2" do
    test "successfully creates an user", %{conn: conn} do
      params = %{
        "name" => "João",
        "password" => "123455",
        "email" => "teste@teste.com",
        "cpf" => "12345678901",
        "address" => %{
          "zip_code" => "12345678"
        }
      }

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(:created)

      assert %{
               "message" => "User criado com sucesso",
               "data" => %{
                 "id" => _id,
                 "email" => "teste@teste.com",
                 "name" => "João"
               }
             } = response
    end
  end
end
