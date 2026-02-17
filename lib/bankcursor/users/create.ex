defmodule Bankcursor.Users.Create do
  alias Bankcursor.Users.User
  alias Bankcursor.Repo
  alias Bankcursor.ViaCep.Client, as: ViaCepClient

  def call(params) do
    with zip_code when is_binary(zip_code) <- get_in(params, ["address", "zip_code"]),
         {:ok, address_from_cep} <- client().call(zip_code) do
      user_provided_address = Map.get(params, "address", %{})

      full_address =
        address_from_cep
        |> transform_cep_data()
        |> Map.merge(user_provided_address)

      params_with_address =
        params
        |> Map.put("addresses", [full_address])
        |> Map.delete("address")

      params_with_address
      |> User.changeset()
      |> Repo.insert()
      |> handle_insert_result_and_create_account()
    else
      nil -> {:error, :zip_code_missing}
      error -> error
    end
  end

  defp transform_cep_data(cep_data) do
    %{
      "street" => cep_data["logradouro"],
      "neighborhood" => cep_data["bairro"],
      "city" => cep_data["localidade"],
      "state" => cep_data["uf"]
    }
  end

  defp client() do
    Application.get_env(:bankcursor, :via_cep_client, ViaCepClient)
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
