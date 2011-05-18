class AddTokenResetPasswordToUsers < ActiveRecord::Migration
  def self.up
    add_column :userdetails, :token_reset_password, :string
  end

  def self.down
    remove_column :userdetails, :token_reset_password
  end
end
