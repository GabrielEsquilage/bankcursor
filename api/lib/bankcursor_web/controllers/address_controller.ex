defmodule BankcursorWeb.AddressController do
  use BankcursorWeb, :controller
  use PhoenixSwagger

  alias Bankcursor.Accounts
  alias Bankcursor.Accounts.Address
  alias Bankcursor.Users
  alias PhoenixSwagger.Schema

  action_fallback BankcursorWeb.FallbackController

  swagger_path :index do
    get("/api/users/{user_id}/addresses")
    summary("List all addresses for a user")

    parameters do
      path(:user_id, :integer, "User ID", required: true, name: :user_id, in: :path)
    end

    response(200, "OK", Schema.ref(:Address))
  end

  def index(conn, %{"user_id" => user_id}) do
    with {:ok, %Users.User{} = user} <- Users.get(user_id) do
      addresses = Accounts.list_addresses_for_user(user)
      render(conn, :index, addresses: addresses)
    end
  end

  swagger_path :create do
    post("/api/users/{user_id}/addresses")
    summary("Create a new address for a user")

    parameters do
      path(:user_id, :integer, "User ID", required: true, name: :user_id, in: :path)
      body(:body, Schema.ref(:Address), "Address parameters", required: true)
    end

    response(201, "Created", Schema.ref(:Address))
    response(400, "Bad Request")
  end

  def create(conn, %{"user_id" => user_id, "address" => address_params}) do
    with {:ok, %Users.User{} = user} <- Users.get(user_id),
         {:ok, %Address{} = address} <- Accounts.create_address(user, address_params) do
      conn
      |> put_status(:created)
      |> render(:show, address: address)
    end
  end

  swagger_path :show do
    get("/api/users/{user_id}/addresses/{id}")
    summary("Show a specific address for a user")

    parameters do
      path(:user_id, :integer, "User ID", required: true, name: :user_id, in: :path)
      path(:id, :integer, "Address ID", required: true, name: :id, in: :path)
    end

    response(200, "OK", Schema.ref(:Address))
    response(404, "Not Found")
  end

  def show(conn, %{"user_id" => user_id, "id" => id}) do
    with {:ok, %Users.User{} = user} <- Users.get(user_id),
         {:ok, %Address{} = address} <- Accounts.get_address_for_user(user, id) do
      render(conn, :show, address: address)
    end
  end

  swagger_path :update do
    put("/api/users/{user_id}/addresses/{id}")
    summary("Update a specific address for a user")

    parameters do
      path(:user_id, :integer, "User ID", required: true, name: :user_id, in: :path)
      path(:id, :integer, "Address ID", required: true, name: :id, in: :path)
      body(:body, Schema.ref(:Address), "Address parameters", required: true)
    end

    response(200, "OK", Schema.ref(:Address))
    response(400, "Bad Request")
    response(404, "Not Found")
  end

  def update(conn, %{"user_id" => user_id, "id" => id, "address" => address_params}) do
    with {:ok, %Users.User{} = user} <- Users.get(user_id),
         {:ok, %Address{} = address} <- Accounts.get_address_for_user(user, id),
         {:ok, %Address{} = updated_address} <- Accounts.update_address(address, address_params) do
      render(conn, :show, address: updated_address)
    end
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete("/api/users/{user_id}/addresses/{id}")
    summary("Delete a specific address for a user")

    parameters do
      path(:user_id, :integer, "User ID", required: true, name: :user_id, in: :path)
      path(:id, :integer, "Address ID", required: true, name: :id, in: :path)
    end

    response(204, "No Content")
    response(404, "Not Found")
  end

  def delete(conn, %{"user_id" => user_id, "id" => id}) do
    with {:ok, %Users.User{} = user} <- Users.get(user_id),
         {:ok, %Address{} = address} <- Accounts.get_address_for_user(user, id),
         :ok <- Accounts.delete_address(address) do
      send_resp(conn, :no_content, "")
    end
  end

  defmodule Schema do
    use PhoenixSwagger

    def swagger_definitions do
      %{
        Address:
          swagger_schema do
            title("Address")
            description("A user's address")

            properties do
              id(:integer, "Address ID")
              street(:string, "Street name")
              number(:string, "House number")
              complement(:string, "Complement")
              neighborhood(:string, "Neighborhood")
              city(:string, "City")
              state(:string, "State")
              zip_code(:string, "Zip Code")
              user_id(:integer, "User ID")
              inserted_at(:string, "Inserted At", format: :"date-time")
              updated_at(:string, "Updated At", format: :"date-time")
            end

            required([:street, :neighborhood, :city, :state, :zip_code, :user_id])

            example(%{
              id: 1,
              street: "Rua Exemplo",
              number: "123",
              complement: "Apto 101",
              neighborhood: "Centro",
              city: "Cidade",
              state: "UF",
              zip_code: "12345678",
              user_id: 1,
              inserted_at: "2025-01-01T12:00:00Z",
              updated_at: "2025-01-01T12:00:00Z"
            })
          end
      }
    end
  end
end
