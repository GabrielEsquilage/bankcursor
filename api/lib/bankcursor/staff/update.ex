defmodule Bankcursor.Staff.Update do
  alias Bankcursor.Repo
  alias Bankcursor.Staff.Password
  alias Bankcursor.Staff.StaffMember

  def reset_password(staff_member) do
    new_password = Password.generate()

    staff_member
    |> StaffMember.changeset(%{password: new_password})
    |> Repo.update()
    |> case do
      {:ok, user} -> {:ok, {user, new_password}}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
