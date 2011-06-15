class AddRoleCmsToUserdetails < ActiveRecord::Migration
  def self.up
    add_column :userdetails, :role_cms, :string

    # Map existing users' nesstar roles to a CMS role
    UserWithoutValidations.find_in_batches(:batch_size => 250) do |users|
      say "Setting CMS role for users #{users.first.user} to #{users.last.user}..."
      users.each do |user|
        user.role_cms = case user.user_role
                        when 'administrator'
                          'administrator'
                        when 'publisher'
                          # TODO: Multiple values?
                          ['manager', 'approver']
                        when /fullauthorisedUser|authorisedUser|affiliateusers/
                          'member'
                        else
                          say "Unknown role #{user.user_role} for user #{user.user}."
                          nil
                        end
        user.save!
      end
    end
    say "Done!"
  end

  def self.down
    remove_column :userdetails, :role_cms
  end
end
