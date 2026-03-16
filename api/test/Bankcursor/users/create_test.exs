defmodule Bankcursor.Users.CreateTest do
  use Bankcursor.DataCase, async: true

  alias Bankcursor.Users

  alias Decimal

  describe "create/1" do
    test "successfully creates a user and an associated account" do
      params = %{
        "name" => "Test User",
        "email" => "test@user.com",
        "password" => "password123",
        "cpf" => "11122233344",
        "address" => %{
          "zip_code" => "12345678"
        }
      }

      {:ok, user, account} = Users.create(params)

      assert user.id
      assert user.email == "test@user.com"
      assert account.user_id == user.id
      assert account.balance == Decimal.new("0")
      assert account.account_number =~ ~r/^\d{6}-\w{1}$/

      # Verify the account is loaded with the user
      loaded_user = Bankcursor.Repo.get!(Bankcursor.Users.User, user.id)
      loaded_user = Bankcursor.Repo.preload(loaded_user, :account)
      assert loaded_user.account.id == account.id
    end

    test "returns error if email is already registered" do
      params = %{
        "name" => "Existing User",
        "email" => "existing@user.com",
        "password" => "password123",
        "cpf" => "11111111111",
        "address" => %{
          "zip_code" => "12345678"
        }
      }

      {:ok, _user, _account} = Users.create(params)

      {:error, :email_already_registered} = Users.create(params)
    end

    test "returns error if CPF is already registered" do
      params = %{
        "name" => "Existing User 2",
        "email" => "existing2@user.com",
        "password" => "password123",
        "cpf" => "22222222222",
        "address" => %{
          "zip_code" => "12345678"
        }
      }

      {:ok, _user, _account} = Users.create(params)

      params_duplicate_cpf = %{
        "name" => "Another User",
        "email" => "another@user.com",
        "password" => "password123",
        "cpf" => "22222222222",
        "address" => %{
          "zip_code" => "12345678"
        }
      }

      {:error, %Ecto.Changeset{errors: [cpf: {"Este CPF já está registrado", _}]} = _changeset} =
        Users.create(params_duplicate_cpf)
    end
  end
end
