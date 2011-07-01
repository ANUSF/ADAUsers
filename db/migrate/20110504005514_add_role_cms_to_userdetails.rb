class AddRoleCmsToUserdetails < ActiveRecord::Migration
  def self.up
    add_column :userdetails, :role_cms, :string

    # Map existing users' nesstar roles to a CMS role
    UserWithoutValidations.find_in_batches(:batch_size => 300) do |users|
      say "Setting CMS role for users #{users.first.user} to #{users.last.user}..."
      users.each do |user|
        begin
          user.role_cms = case user.user_role
                          when 'administrator'
                            'administrator'
                          when 'publisher'
                            'approver'
                          when /fullauthorisedUser|authorisedUser|affiliateusers/
                            'member'
                          else
                            say "Unknown role #{user.user_role} for user #{user.user}."
                            nil
                          end
          # For some reason, relations aren't loaded, so we do a reload first
          user.reload
          user.save!
        rescue
          say "Skipping #{user.user} - error saving their record (check for non-UTF8 chars in their username)"
        end
      end
    end
    say "Done!"
  end

  def self.down
    remove_column :userdetails, :role_cms
  end
end
