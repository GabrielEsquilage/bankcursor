defmodule Bankcursor.Repo.Migrations.AddInitialAdmin do
  use Ecto.Migration

  def up do
    # Usando SQL direto para evitar dependência do schema Elixir em migrations
    # A senha será 'password123'
    password_hash = Pbkdf2.hash_pwd_salt("password123")
    
    execute """
    INSERT INTO users (name, email, password_hash, cpf, role, inserted_at, updated_at)
    VALUES ('Administrador', 'admin@bankcursor.com', '#{password_hash}', '00000000001', 'admin', NOW(), NOW())
    """
  end

  def down do
    execute "DELETE FROM users WHERE email = 'admin@bankcursor.com'"
  end
end
