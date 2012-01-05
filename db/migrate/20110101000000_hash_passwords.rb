class HashPasswords < ActiveRecord::Migration
  def self.up
    skip_users = ['admin', 'deployer', 'nobody']

    if User::HASH_PASSWORDS
      UserWithoutValidations.where("user NOT IN (?)", skip_users).find_in_batches(:batch_size => 200) do |users|
        say "Hashing passwords for users #{users.first.user} to #{users.last.user}..."
        users.each do |user|
          begin
            user.password = user.read_attribute(:password)
            user.save
          rescue
            say "Skipping #{user.user} - error saving their record (check for non-UTF8 chars in their username)"
          end
        end
      end
      say "Done!"
    end
  end

  def self.down
    if User::HASH_PASSWORDS
      raise "Can't reverse password hashing."
    end
  end
end
