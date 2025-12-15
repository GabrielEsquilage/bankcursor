defmodule Bankcursor.Accounts.TransactionDigester do
  alias Bankcursor.Accounts.TransactionRecord
  alias Bankcursor.Users.User

  @doc """
  Generates an MD5 digest for a transaction based on user and transaction details.
  """
  def generate(%User{} = user, %TransactionRecord{} = transaction_record) do
    data_to_hash =
      :erlang.term_to_binary({
        user.id,
        user.password_hash,
        transaction_record.type,
        transaction_record.value,
        transaction_record.inserted_at
      })

    :crypto.hash(:md5, data_to_hash)
  end

  @doc """
  Validates a transaction record's digest against a re-calculated digest.
  """
  def validate(%User{} = user, %TransactionRecord{} = transaction_record) do
    if transaction_record.validation_digest do
      generated_digest = generate(user, transaction_record)
      generated_digest == transaction_record.validation_digest
    else
      false
    end
  end
end
