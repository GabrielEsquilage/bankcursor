defmodule BankcursorWeb.Router do
  use BankcursorWeb, :router
  use PhoenixSwagger

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug BankcursorWeb.Plugs.Auth
  end

  scope "/api" do
    pipe_through :api
    forward "/docs", PhoenixSwagger.Plug.SwaggerUI, otp_app: :bankcursor, swagger_file: "swagger.json"
  end

  scope "/api", BankcursorWeb do
    pipe_through :api

    get "/", WelcomeController, :index

    resources "/users", UsersController, only: [:create]
    post "/users/login", UsersController, :login
  end

  scope "/api", BankcursorWeb do
    pipe_through [:api, :auth]


        resources "/users", UsersController, only: [:update, :delete, :show]
    post "/accounts", AccountsController, :create
    post "/accounts/transactions", AccountsController, :transaction
    post "/accounts/deposit", AccountsController, :deposit
    post "/accounts/withdraw", AccountsController, :withdraw
  end

  if Application.compile_env(:bankcursor, :dev_routes) do

    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BankcursorWeb.Telemetry
    end
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0.0",
        title: "Bankcursor API"
      }
    }
  end
end
