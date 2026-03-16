defmodule Bankcursor.Repo.Migrations.AddInitialStaffAdmin do
  use Ecto.Migration

  def up do
    password_hash = Pbkdf2.hash_pwd_salt("password123")
    
    execute """
    INSERT INTO staff_members (name, email, password_hash, staff_number, role, inserted_at, updated_at)
    VALUES ('Administrador Master', 'admin@bankcursor.com', '#{password_hash}', 'STF-0001', 'admin', NOW(), NOW())
    """
  end

  def down do
    execute "DELETE FROM staff_members WHERE email = 'admin@bankcursor.com'"
  end
end
