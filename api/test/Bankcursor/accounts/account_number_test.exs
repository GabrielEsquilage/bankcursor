defmodule Bankcursor.Accounts.AccountNumberTest do
  use ExUnit.Case, async: true

  alias Bankcursor.Accounts.AccountNumber

  describe "generate/0" do
    test "generates a valid account number" do
      account_number = AccountNumber.generate()

      assert account_number =~ ~r/^\d{6}-\w{1}$/

      [digits, check_digit] = String.split(account_number, "-")

      # Re-calculate the check digit to verify its correctness
      weights = Stream.cycle([2, 3, 4, 5, 6, 7])

      sum =
        digits
        |> String.to_charlist()
        |> Enum.map(&(&1 - ?0))
        |> Enum.zip(weights)
        |> Enum.map(fn {digit, weight} -> digit * weight end)
        |> Enum.sum()

      remainder = rem(sum, 11)
      expected_check_digit = 11 - remainder

      calculated_check_digit =
        cond do
          expected_check_digit == 10 -> "X"
          expected_check_digit == 11 -> "0"
          true -> Integer.to_string(expected_check_digit)
        end

      assert check_digit == calculated_check_digit
    end
  end
end
