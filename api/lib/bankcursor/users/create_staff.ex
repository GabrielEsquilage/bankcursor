defmodule Bankcursor.Users.CreateStaff do
  alias Bankcursor.Users.User
  alias Bankcursor.Repo

  def call(params) do
    params
    |> User.changeset()
    |> Repo.insert()
    |> case do
      {:ok, user} -> {:ok, user, nil}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
