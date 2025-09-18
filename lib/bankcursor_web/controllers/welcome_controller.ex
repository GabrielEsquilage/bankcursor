defmodule BankcursorWeb.WelcomeController do
    use BankcursorWeb, :controller
    use PhoenixSwagger

    swagger_path :index do
        get "/api"
        summary "Welcome message"
        description "Returns a welcome message."
        response 200, "OK", Schema.ref(:Welcome)
    end

    def index(conn, _params) do
        conn
        |> put_status(:ok)
        |> json(%{message: "bem vindo ao bankcursor"})
    end

    defmodule Schema do
        use PhoenixSwagger

        def swagger_definitions do
            %{
                Welcome: swagger_schema do
                    properties do
                        message :string, "Welcome message"
                    end
                end
            }
        end
    end
end