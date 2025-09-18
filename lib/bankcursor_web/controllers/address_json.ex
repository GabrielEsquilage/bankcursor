defmodule BankcursorWeb.AddressJSON do
  alias Bankcursor.Accounts.Address

  def index(%{addresses: addresses}) do
    %{data: for(address <- addresses, do: data(address))}
  end

  def show(%{address: address}) do
    %{data: data(address)}
  end

  defp data(%Address{} = address) do
    %{
      id: address.id,
      street: address.street,
      number: address.number,
      complement: address.complement,
      neighborhood: address.neighborhood,
      city: address.city,
      state: address.state,
      zip_code: address.zip_code,
      user_id: address.user_id
    }
  end
end
