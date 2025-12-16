defmodule Bankcursor.Users.CPF do
  @doc """
  Validates a Brazilian CPF number.
  """
  def valid?(cpf) when is_binary(cpf) do
    cpf = String.replace(cpf, ~r/[^\d]/, "")

    if String.length(cpf) != 11 or all_same_digits?(cpf) do
      false
    else
      digits = String.to_charlist(cpf) |> Enum.map(&(&1 - ?0))
      validate_digits(digits)
    end
  end

  defp all_same_digits?(cpf) do
    Regex.match?(~r/^(\d)\1{10}$/, cpf)
  end

  defp validate_digits(digits) do
    {rest, [d1, d2]} = Enum.split(digits, 9)
    dv1 = calculate_dv(rest)
    dv2 = calculate_dv(rest ++ [dv1])

    dv1 == d1 and dv2 == d2
  end

  defp calculate_dv(digits) do
    sum =
      digits
      |> Enum.with_index()
      |> Enum.reduce(0, fn {digit, index}, acc ->
        acc + digit * (length(digits) + 1 - index)
      end)

    remainder = rem(sum, 11)

    if remainder < 2 do
      0
    else
      11 - remainder
    end
  end
end
