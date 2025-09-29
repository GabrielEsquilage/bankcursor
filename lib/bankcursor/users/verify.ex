defmodule Bankcursor.Users.Verify do
  alias Bankcursor.Users

  def call(%{"identifier" => identifier, "password" => password}) do
    user =
      cond do
        String.contains?(identifier, "@") -> Users.get_by_email(identifier)
        String.length(identifier) == 11 && String.match?(identifier, ~r/^\d+$/) -> Users.get_by_cpf(identifier)
        String.contains?(identifier, "-") -> Users.get_by_account_number(identifier)
        true -> {:error, :invalid_identifier}
      end

    case user do
      {:ok, user} -> verify(user, password)
      {:error, _} = error -> error
    end
  end

  def verify(user, password) do
    case Pbkdf2.verify_pass(password, user.password_hash) do
      true -> {:ok, user}
      false -> {:error, :unauthorized}
    end
  end
end
