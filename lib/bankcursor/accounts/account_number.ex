
defmodule Bankcursor.Accounts.AccountNumber do
  @moduledoc """
  Generates a unique account number with a check digit.
  """

  @doc """
  Generates a new account number in the format XXXXXX-Y.
  """
  def generate do
    six_digits = generate_six_digits()
    check_digit = calculate_check_digit(six_digits)
    "#{six_digits}-#{check_digit}"
  end

  defp generate_six_digits do
    :crypto.strong_rand_bytes(3)
    |> :binary.decode_unsigned()
    |> Integer.to_string()
    |> String.pad_leading(6, "0")
    |> String.slice(0, 6)
  end

  defp calculate_check_digit(digits) do
    weights = Stream.cycle([2, 3, 4, 5, 6, 7])

    sum =
      digits
      |> String.to_charlist()
      |> Enum.map(&(&1 - ?0))
      |> Enum.zip(weights)
      |> Enum.map(fn {digit, weight} -> digit * weight end)
      |> Enum.sum()

    remainder = rem(sum, 11)
    check_digit = 11 - remainder

    cond do
      check_digit == 10 -> "X"
      check_digit == 11 -> "0"
      true -> Integer.to_string(check_digit)
    end
  end
end
