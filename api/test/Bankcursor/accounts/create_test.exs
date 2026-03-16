defmodule Bankcursor.Accounts.CreateTest do
  use Bankcursor.DataCase, async: true

  alias Decimal

  describe "create/1" do
    # test "successfully creates an account" do
    #   {:ok, user, _account} =
    #     Users.create(%{
    #       "name" => "Test User",
    #       "email" => "test@user.com",
    #       "password" => "password123",
    #       "cpf" => "11122233344",
    #       "address" => %{
    #         "zip_code" => "12345678"
    #       }
    #     })

    #   params = %{
    #     "user_id" => user.id,
    #     "balance" => "100.0"
    #   }

    #   {:ok, account} = Accounts.create(params)

    #   assert account.user_id == user.id
    #   assert account.balance == Decimal.new("100.0")
    #   assert account.account_number =~ ~r/^\d{6}-\w{1}$/
    # end
  end
end
