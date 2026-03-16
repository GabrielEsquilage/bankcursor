defmodule Bankcursor.Staff.StaffMember do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bankcursor.Repo

  schema "staff_members" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :staff_number, :string
    field :role, :string, default: "collaborator"

    timestamps()
  end

  def changeset(staff, params \\ %{}) do
    staff
    |> cast(params, [:name, :email, :password, :role])
    |> validate_required([:name, :email, :password, :role])
    |> unique_constraint(:email)
    |> add_staff_number()
    |> add_password_hash()
  end

  defp add_staff_number(changeset) do
    if get_field(changeset, :staff_number) do
      changeset
    else
      # Gera STF-000X baseado no count total + 1
      count = Repo.aggregate(__MODULE__, :count, :id) || 0
      staff_number = "STF-" <> String.pad_leading("#{count + 1}", 4, "0")
      put_change(changeset, :staff_number, staff_number)
    end
  end

  defp add_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(password))
  end
  defp add_password_hash(changeset), do: changeset
end
