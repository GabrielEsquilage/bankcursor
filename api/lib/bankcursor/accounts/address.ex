defmodule Bankcursor.Accounts.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field :street, :string
    field :number, :string
    field :complement, :string
    field :neighborhood, :string
    field :city, :string
    field :state, :string
    field :zip_code, :string
    belongs_to :user, Bankcursor.Users.User

    timestamps()
  end

  def swagger_schema do
    %{
      type: :object,
      properties: %{
        id: %{type: :integer, format: :int64},
        street: %{type: :string},
        number: %{type: :string},
        complement: %{type: :string},
        neighborhood: %{type: :string},
        city: %{type: :string},
        state: %{type: :string},
        zip_code: %{type: :string},
        user_id: %{type: :integer, format: :int64},
        inserted_at: %{type: :string, format: :"date-time"},
        updated_at: %{type: :string, format: :"date-time"}
      },
      required: [:street, :neighborhood, :city, :state, :zip_code, :user_id]
    }
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:street, :number, :complement, :neighborhood, :city, :state, :zip_code])
    |> validate_required([:street, :neighborhood, :city, :state, :zip_code])
    |> validate_length(:zip_code, is: 8)
  end
end
