defmodule Bankcursor.Accounts do
  alias Bankcursor.Accounts.Create
  alias Bankcursor.Accounts.CreateForUser
  alias Bankcursor.Accounts.Transfer
  alias Bankcursor.Accounts.Deposit
  alias Bankcursor.Accounts.Withdraw
  alias Bankcursor.Accounts.Get

  # Address delegates
  alias Bankcursor.Accounts.Address

  defdelegate create(params), to: Create, as: :call
  defdelegate create_for_user(user), to: CreateForUser, as: :call
  defdelegate transfer(params), to: Transfer, as: :call
  defdelegate deposit(params), to: Deposit, as: :call
  defdelegate withdraw(params), to: Withdraw, as: :call
  defdelegate get_by_account_number(account_number), to: Get, as: :call_by_account_number
  defdelegate get_transaction(transaction_id), to: Get, as: :call_by_id

  defdelegate list_addresses_for_user(user), to: Address.List, as: :call
  defdelegate create_address(user, params), to: Address.Create, as: :call
  defdelegate get_address_for_user(user, id), to: Address.Get, as: :call
  defdelegate update_address(address, params), to: Address.Update, as: :call
  defdelegate delete_address(address), to: Address.Delete, as: :call
end
