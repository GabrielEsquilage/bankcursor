defmodule Bankcursor.Accounts do
    alias Bankcursor.Accounts.Create
    alias Bankcursor.Accounts.Transaction
    alias Bankcursor.Accounts.Deposit
    alias Bankcursor.Accounts.Withdraw
    alias Bankcursor.Accounts.ListAddresses
    alias Bankcursor.Accounts.CreateAddress
    alias Bankcursor.Accounts.GetAddress
    alias Bankcursor.Accounts.UpdateAddress
    alias Bankcursor.Accounts.DeleteAddress

    defdelegate create(params), to: Create, as: :call
    defdelegate transaction(params), to: Transaction, as: :call
    defdelegate deposit(params), to: Deposit, as: :call
    defdelegate withdraw(params), to: Withdraw, as: :call

    defdelegate list_addresses_for_user(user), to: ListAddresses, as: :call
    defdelegate create_address(user, params), to: CreateAddress, as: :call
    defdelegate get_address_for_user(user, id), to: GetAddress, as: :call
    defdelegate update_address(address, params), to: UpdateAddress, as: :call
    defdelegate delete_address(address), to: DeleteAddress, as: :call
end
