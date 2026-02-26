defmodule Bankcursor.Staff.Password do
  def generate(length \ 12) do
    :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)
  end
end
