defmodule Bankcursor.Accounts.Create do
  alias Bankcursor.Accounts.Account
  alias Bankcursor.Repo
  alias Bankcursor.Users

  def call(params) do
    with {:ok, user} <- get_user(params),
         :ok <- validate_user(user) do
      params
      |> Account.changeset()
      |> Repo.insert()
    else
      {:error, :user_id_missing} -> {:error, :user_id_missing}
      {:error, :not_found} -> {:error, :user_not_found}
      {:error, missing_fields} -> {:error, {:user_missing_fields, missing_fields}}
    end
  end

  defp get_user(params) do
    case Map.get(params, "user_id") do
      nil -> {:error, :user_id_missing}
      user_id -> Users.get(user_id)
    end
  end

  defp validate_user(user) do
    required_fields = [:name, :email, :cpf]
    missing_fields =
      required_fields
      |> Enum.filter(fn field ->
        case Map.get(user, field) do
          nil -> true
          "" -> true
          _ -> false
        end
      end)

    if Enum.empty?(missing_fields) do
      :ok
    else
      {:error, missing_fields}
    end
  end
end