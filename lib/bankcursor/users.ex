defmodule Bankcursor.Users do
  alias Bankcursor.Users.Create
  alias Bankcursor.Users.Delete
  alias Bankcursor.Users.Get
  alias Bankcursor.Users.Update
  alias Bankcursor.Users.Verify

  alias Bankcursor.Users.CreateStaff

  defdelegate create(params), to: Create, as: :call
  defdelegate create_staff(params), to: CreateStaff, as: :call
  defdelegate delete(id), to: Delete, as: :call
  defdelegate get(id), to: Get, as: :call
  defdelegate get_with_associations(id), to: Get, as: :call_with_associations
  defdelegate get_by_email(email), to: Get, as: :call_by_email
  defdelegate get_by_cpf(cpf), to: Get, as: :call_by_cpf
  defdelegate get_by_account_number(account_number), to: Get, as: :call_by_account_number
  defdelegate update(params), to: Update, as: :call
  defdelegate login(params), to: Verify, as: :call
end
