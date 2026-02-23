defmodule Bankcursor.Users.Create do
  alias Bankcursor.Users.User
  alias Bankcursor.Repo

  def call(params) do
    params
    |> User.changeset()
    |> Repo.insert()
    |> handle_insert_result_and_create_account()
  end

  defp handle_insert_result_and_create_account({:ok, user}) do
    case Bankcursor.Accounts.CreateForUser.call(user) do
      {:ok, account} -> {:ok, user, account}
      {:error, reason} -> {:error, {:account_creation_failed, reason}}
    end
  end

  defp handle_insert_result_and_create_account(
         {:error, %Ecto.Changeset{valid?: false} = changeset}
       ) do
    if Keyword.get(changeset.errors, :email) ==
         {"Este e-mail já está registrado",
          [constraint: :unique, constraint_name: "users_email_index"]} do
      {:error, :email_already_registered}
    else
      {:error, changeset}
    end
  end
end
