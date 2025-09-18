defmodule BankcursorWeb.UsersController do
    use BankcursorWeb, :controller
    use PhoenixSwagger

    alias Bankcursor.Users
    alias Users.User

    alias BankcursorWeb.Token

    action_fallback BankcursorWeb.FallbackController

    swagger_path :create do
      post "/api/users"
      summary "Create a user"
      description "Creates a new user."
      parameters do
        body :body, Schema.ref(:User), "User parameters"
      end
      response 201, "Created", Schema.ref(:User)
      response 400, "Bad Request"
    end

    def create(conn, params) do
        with {:ok, %User{} = user} <- Users.create(params) do
            conn
            |> put_status(:created)
            |> render(:create, user: user)
        end
    end

    swagger_path :delete do
      PhoenixSwagger.Path.delete "/api/users/{id}"
      summary "Delete a user"
      description "Deletes a user."
      parameters do
        path :id, :integer, "User ID", required: true
      end
      response 200, "OK"
      response 404, "Not Found"
    end

    def delete(conn, %{"id" => id}) do
        with {:ok, %User{} = user} <- Users.delete(id) do
            conn
            |> put_status(:ok)
            |> render(:delete, user: user)
        end
    end

    swagger_path :show do
      get "/api/users/{id}"
      summary "Show a user"
      description "Shows a user."
      parameters do
        path :id, :integer, "User ID", required: true
      end
      response 200, "OK", Schema.ref(:User)
      response 404, "Not Found"
    end

    def show(conn, %{"id" => id}) do
        with {:ok, %User{} = user} <- Users.get(id) do
            conn
            |> put_status(:ok)
            |> render(:get, user: user)
        end
    end

    swagger_path :update do
      put "/api/users/{id}"
      summary "Update a user"
      description "Updates a user."
      parameters do
        path :id, :integer, "User ID", required: true
        body :body, Schema.ref(:User), "User parameters"
      end
      response 200, "OK", Schema.ref(:User)
      response 400, "Bad Request"
      response 404, "Not Found"
    end

    def update(conn, params) do
        with {:ok, %User{} = user} <- Users.update(params) do
            conn
            |> put_status(:ok)
            |> render(:update, user: user)
        end
    end

    swagger_path :login do
      post "/api/users/login"
      summary "User login"
      description "Authenticates a user and returns a JWT in the Authorization header."

      parameters do
        body :body, %{
          "email" => %{type: :string, required: true, description: "User email"},
          "password" => %{type: :string, required: true, description: "User password"}
        }, "User credentials"
      end

      response 200, "Successful authentication",
        %{"message" => %{type: :string, description: "Success message"}},
        [headers: %{
          "Authorization" => %{
            description: "Bearer token for authentication",
            type: :string
          }
        }]
      response 401, "Unauthorized"
    end
    def login(conn, params) do
        with {:ok, %User{} = user} <- Users.login(params) do
            token = Token.sign(user)

            conn
            |> put_resp_header("authorization", "Bearer #{token}")
            |> put_status(:ok)
            |> render(:login)
        end
    end

    defmodule Schema do
      use PhoenixSwagger
      def swagger_definitions do
        %{
          User: swagger_schema do
            title "User"
            description "A user of the system"
            properties do
              name :string, "Name"
              email :string, "Email"
              cep :string, "CEP"
              password :string, "Password"
            end
            example %{
              name: "John Doe",
              email: "john.doe@example.com",
              cep: "12345678",
              password: "password"
            }
          end
        }
      end
    end
end
