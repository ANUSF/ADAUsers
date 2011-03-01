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

  describe "getters" do
    it "gets the affiliation" do
      # Not in Australia
      user = User.make(:no_affiliation,
                       :country => Country.find_by_Countryname("New Zealand"),
                       :non_australian_affiliation => "University of Auckland",
                       :non_australian_type => User.new.non_aust_inst_types[0])
      user.affiliation.should == "University of Auckland"

      # Australian uni
      user = User.make(:no_affiliation,
                       :country => User::AUSTRALIA,
                       :austinstitution => 'Uni',
                       :australian_uni => AustralianUni.find_by_Longuniname("Australian National University"))
      user.affiliation.should == "Australian National University"

      # Australian government agency
      user = User.make(:no_affiliation,
                       :country => User::AUSTRALIA,
                       :austinstitution => 'Dept',
                       :australian_gov => AustralianGov.find_by_value("DEducation"))
      user.affiliation.should == "Department of Education, Employment and Workplace Relations"

      # Other Australian affiliation
      user = User.make(:no_affiliation,
                       :country => User::AUSTRALIA,
                       :austinstitution => 'Other',
                       :other_australian_affiliation => "BarCamp Canberra",
                       :other_australian_type => User.new.other_aust_inst_types[5])
      user.affiliation.should == "BarCamp Canberra"
    end
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
      user.grant_pending_datasets!(["abc123"], :a)
      user.permissions_a.where(:datasetID => "abc123").first.permissionvalue.should == 1

      user = User.make
      user.permissions_b.create(:datasetID => "abc123", :permissionvalue => 0)
      user.grant_pending_datasets!(["abc123"], :b)
      user.permissions_b.where(:datasetID => "abc123").first.permissionvalue.should == 6
    end
  end
end
