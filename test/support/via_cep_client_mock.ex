
defmodule Bankcursor.ViaCep.ClientMock do
  def call(_cep) do
    {:ok,
     %{
       "logradouro" => "Praça da Sé",
       "bairro" => "Sé",
       "localidade" => "São Paulo",
       "uf" => "SP"
     }}
  end
end
