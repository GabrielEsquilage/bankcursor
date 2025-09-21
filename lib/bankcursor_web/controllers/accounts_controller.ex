defmodule BankcursorWeb.AccountsController do
    use BankcursorWeb, :controller
    use PhoenixSwagger

    alias Bankcursor.Accounts
    alias Accounts.Account
    alias BankcursorWeb.ErrorJSON

    action_fallback BankcursorWeb.FallbackController

    swagger_path :create do
      post "/api/accounts"
      summary "Create an account"
      description "Creates a new account for a user."
      parameters do
        body :body, Schema.ref(:Account), "Account parameters"
      end
      response 201, "Created", Schema.ref(:Account)
      response 400, "Bad Request"
    end

    def create(conn, params) do
        with {:ok, %Account{} = account} <- Accounts.create(params) do
          conn
          |> put_status(:created)
          |> render(:create, account: account)
        else
          {:error, :user_id_missing} ->
            conn
            |> put_status(:bad_request)
            |> put_view(ErrorJSON)
            |> render(:error, %{message: "user_id is missing"})
          {:error, :user_not_found} ->
            conn
            |> put_status(:not_found)
            |> put_view(ErrorJSON)
            |> render(:error, %{message: "User not found"})
          {:error, {:user_missing_fields, missing_fields}} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(ErrorJSON)
            |> render(:error, %{message: "User is missing required fields: #{inspect(missing_fields)}"})
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(ErrorJSON)
            |> render(:error, %{changeset: changeset})
        end
    end

    swagger_path :deposit do
      post "/api/accounts/deposit"
      summary "Deposit into an account"
      description "Deposits a value into an account."
      parameters do
        body :body, Schema.ref(:Deposit), "Deposit parameters"
      end
      response 200, "OK", Schema.ref(:Account)
      response 400, "Bad Request"
      response 404, "Not Found"
    end

    def deposit(conn, params) do
      with {:ok, %Account{} = account} <- Accounts.deposit(params) do
        conn
        |> put_status(:ok)
        |> render(:deposit, account: account)
      end
    end

    swagger_path :withdraw do
      post "/api/accounts/withdraw"
      summary "Withdraw from an account"
      description "Withdraws a value from an account."
      parameters do
        body :body, Schema.ref(:Withdraw), "Withdraw parameters"
      end
      response 200, "OK", Schema.ref(:Account)
      response 400, "Bad Request"
      response 404, "Not Found"
    end

    def withdraw(conn, params) do
      with {:ok, %Account{} = account} <- Accounts.withdraw(params) do
        conn
        |> put_status(:ok)
        |> render(:withdraw, account: account)
      end
    end

    swagger_path :transaction do
      post "/api/accounts/transactions"
      summary "Transfer between accounts"
      description "Transfers a value between two accounts."
      parameters do
        body :body, Schema.ref(:Transaction), "Transaction parameters"
      end
      response 200, "OK", Schema.ref(:TransactionRecord)
      response 400, "Bad Request"
      response 404, "Not Found"
    end

    def transaction(conn, params) do
      with {:ok, transaction} <- Accounts.transaction(params) do
        conn
        |> put_status(:ok)
        |> render(:transaction, transaction: transaction)
      end
    end

    defmodule Schema do
      use PhoenixSwagger
      def swagger_definitions do
        %{
          Account: swagger_schema do
            title "Account"
            description "A bank account"
            properties do
              balance :decimal, "Balance"
              user_id :integer, "User ID"
            end
            example %{
              balance: 100.0,
              user_id: 1
            }
          end,
          Deposit: swagger_schema do
            title "Deposit"
            description "A deposit into an account"
            properties do
              account_id :integer, "Account ID"
              value :decimal, "Value"
            end
            example %{
              account_id: 1,
              value: 50.0
            }
          end,
          Withdraw: swagger_schema do
            title "Withdraw"
            description "A withdrawal from an account"
            properties do
              account_id :integer, "Account ID"
              value :decimal, "Value"
            end
            example %{
              account_id: 1,
              value: 20.0
            }
          end,
          Transaction: swagger_schema do
            title "Transaction"
            description "A transfer between accounts"
            properties do
              from_account_id :integer, "From Account ID"
              to_account_id :integer, "To Account ID"
              value :decimal, "Value"
            end
            example %{
              from_account_id: 1,
              to_account_id: 2,
              value: 10.0
            }
          end,
          TransactionRecord: swagger_schema do
            title "Transaction Record"
            description "A record of a transaction"
            properties do
              type :string, "Type"
              value :decimal, "Value"
              account_id :integer, "Account ID"
              recipient_account_id :integer, "Recipient Account ID"
            end
          end
        }
      end
    end
end
