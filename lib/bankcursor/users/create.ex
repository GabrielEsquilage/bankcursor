defmodule Bankcursor.Users.Create do
    alias Bankcursor.Users.User
    alias Bankcursor.Repo
    alias Bankcursor.ViaCep.Client, as: ViaCepClient

    def call(%{"cep" => cep} = params) do
        with {:ok, _result} <- client().call(cep) do
            params
            |> User.changeset()
            |> Repo.insert()
            |> handle_insert_result()
        end
    end

    defp client() do
      Application.get_env(:bankcursor, :via_cep_client, ViaCepClient)
    end

    defp handle_insert_result({:ok, user}), do: {:ok, user}
    defp handle_insert_result({:error, %Ecto.Changeset{valid?: false} = changeset}) do
        if Keyword.get(changeset.errors, :email) == {"has already been taken", [constraint: :unique, constraint_name: "users_email_index"]} do
            {:error, :email_already_registered}
        else
            {:error, changeset}
        end
    end
end
