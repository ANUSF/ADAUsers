class HashPasswords < ActiveRecord::Migration
  def self.up
    UserWithoutValidations.find_in_batches(:batch_size => 200) do |users|
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

  def self.down
    raise "Can't reverse password hashing."
  end
end
