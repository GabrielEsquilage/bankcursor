defmodule Bankcursor.Accounts do
    alias Bankcursor.Accounts.Create
    alias Bankcursor.Accounts.Transaction
    alias Bankcursor.Accounts.Deposit
    alias Bankcursor.Accounts.Withdraw

    defdelegate create(params), to: Create, as: :call
    defdelegate transaction(params), to: Transaction, as: :call
    defdelegate deposit(params), to: Deposit, as: :call
    defdelegate withdraw(params), to: Withdraw, as: :call
end
