require 'spec_helper'

describe User do
  describe "validations" do
    it "saves valid users" do
      user = User.make_unsaved
      user.should be_valid
      user.save!
    end

    it "requires a user name" do
      user = User.make_unsaved(:user => '')
      user.should_not be_valid
    end

    # ...
  end

  describe "setters" do
    it "sets the role" do
      user = User.make
      user.user_role.should == "affiliateusers"
      user.update_role! "administrator"
      user.user_role.should == "administrator"
    end
  end
end
