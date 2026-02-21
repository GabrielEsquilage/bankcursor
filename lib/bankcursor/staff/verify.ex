defmodule Bankcursor.Staff.Verify do
  alias Bankcursor.Staff.StaffMember
  alias Bankcursor.Repo

  def call(%{"identifier" => email, "password" => password}) do
    case Repo.get_by(StaffMember, email: email) do
      nil -> {:error, :not_found}
      staff -> 
        if Pbkdf2.verify_pass(password, staff.password_hash) do
          {:ok, staff}
        else
          {:error, :unauthorized}
        end
    end
  end
end
