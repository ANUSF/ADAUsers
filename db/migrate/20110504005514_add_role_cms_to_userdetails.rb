class AddRoleCmsToUserdetails < ActiveRecord::Migration
  def self.up
    add_column :userdetails, :role_cms, :string

    # TODO: Map existing users' nesstar roles to a CMS role
  end

  def self.down
    remove_column :userdetails, :role_cms
  end
end
