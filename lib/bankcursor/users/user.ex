defmodule Bankcursor.Users.User do
    use Ecto.Schema
    import Ecto.Changeset
    alias Ecto.Changeset
    alias Bankcursor.Accounts.Account

    

    @required_params_create [:name, :password, :email, :cpf]
    @required_params_update [:name, :email, :cpf]

    schema "users" do
        field :name, :string
        field :password, :string, virtual: true
        field :password_hash, :string
        field :email, :string
        field :cpf, :string
        has_one :account, Account
        has_many :addresses, Bankcursor.Accounts.Address

        timestamps()
    end

    def swagger_schema do
    %{
      type: :object,
      properties: %{
        id: %{type: :integer, format: :int64},
        name: %{type: :string},
        email: %{type: :string, format: :email},
        cpf: %{type: :string},
        inserted_at: %{type: :string, format: :"date-time"},
        updated_at: %{type: :string, format: :"date-time"}
      },
      required: [:name, :email, :cpf] # For creation, adjust as needed for update
    }
  end

    def changeset(params) do
        %__MODULE__{}
        |> cast(params, @required_params_create ++ [:addresses])
        |> validate_required(@required_params_create)
        |> unique_constraint(:email, message: "Este e-mail já está registrado")
        |> unique_constraint(:cpf, message: "Este CPF já está registrado")
        |> validate_length(:name, min: 3)
        |> validate_format(:email, ~r/@/)
        |> validate_length(:cpf, is: 11)
        |> add_password_hash()
        |> cast_assoc(:addresses, with: &Bankcursor.Accounts.Address.changeset/2)
    end

    def changeset(user, params) do
        user
        |> cast(params, @required_params_update)
        #|> validate_required(@required_params_update)
        |> unique_constraint(:email, message: "Este e-mail já está registrado")
        |> unique_constraint(:cpf, message: "Este CPF já está registrado")
        |> validate_length(:name, min: 3)
        |> validate_format(:email, ~r/@/)
        |> validate_length(:cpf, is: 11)
        |> add_password_hash()
    end

    defp add_password_hash(%Changeset{valid?: true, changes: %{password: password}} = changeset) do
        change(changeset, Pbkdf2.add_hash(password))
    end

    defp add_password_hash(changeset), do: changeset
end
