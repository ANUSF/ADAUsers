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

    it "grants access to pending datasets" do
      user = User.make
      user.permissions_a.create(:datasetID => "abc123", :permissionvalue => 0)
      user.grant_pending_datasets!(["abc123"])
      user.permissions_a.where(:datasetID => "abc123").first.permissionvalue.should == 1
    end
  end
end
