
defmodule Bankcursor.Accounts.CreateForUserTest do
  use Bankcursor.DataCase, async: true

  alias Bankcursor.Accounts
  alias Bankcursor.Users
  alias Decimal

  describe "create_for_user/1" do
    test "successfully creates an account for a user" do
      # Create a user to associate the account with
      {:ok, user} = 
        Users.create(%{
          "name" => "Test User",
          "email" => "test@user.com",
          "password" => "password123",
          "cpf" => "11122233344",
          "address" => %{
            "zip_code" => "12345678"
          }
        })

      {:ok, account} = Accounts.create_for_user(user)

      assert account.user_id == user.id
      assert account.balance == Decimal.new("0")
      assert account.account_number =~ ~r/^\d{6}-\w{1}$/
    end
  end
end
