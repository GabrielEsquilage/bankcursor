defmodule Bankcursor.Users.Get do
  alias Bankcursor.Users.User
  alias Bankcursor.Repo
  import Ecto.Query

  def call(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def call_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def call_by_cpf(cpf) do
    case Repo.get_by(User, cpf: cpf) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def call_by_account_number(account_number) do
    case Repo.one(
           from u in User,
             join: a in assoc(u, :account),
             where: a.account_number == ^account_number
         ) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
