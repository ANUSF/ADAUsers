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

    it "provides correct values for derived attributes" do
      # Other Australian affiliation
      user = User.make(:no_affiliation,
                       :country => User::AUSTRALIA,
                       :austinstitution => 'Other',
                       :other_australian_affiliation => "BarCamp Canberra",
                       :other_australian_type => User.new.other_aust_inst_types[5])
      user = User.find(user.user)
      user.other_australian_affiliation.should == "BarCamp Canberra"
      user.other_australian_type.should == User.new.other_aust_inst_types[5]

      # Non-Australian affiliation
      user = User.make(:no_affiliation,
                       :country => Country.find_by_Countryname("New Zealand"),
                       :non_australian_affiliation => "University of Auckland",
                       :non_australian_type => User.new.non_aust_inst_types[0])
      user = User.find(user.user)
      user.non_australian_affiliation.should == "University of Auckland"
      user.non_australian_type.should == User.new.non_aust_inst_types[0]

      # Australian uni
      user = User.make(:no_affiliation,
                       :country => User::AUSTRALIA,
                       :austinstitution => 'Uni',
                       :australian_uni => AustralianUni.find_by_Longuniname("Australian National University"))
      user = User.find(user.user)
      user.other_australian_affiliation.should == nil
      user.other_australian_type.should == nil
      user.non_australian_affiliation.should == nil
      user.non_australian_type.should == nil
    end

    it "checks access to general datasets" do
      user = User.make

      accessLevel = AccessLevel.make
      accessLevelPending = AccessLevel.make
      accessLevelNoAccess = AccessLevel.make
      user.permissions_a.create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)
      user.permissions_a.create(:datasetID => accessLevelPending.datasetID, :permissionvalue => 0)

      user.access_permissions(accessLevel).should == {:browse => true, :analyse => true, :download => true}
      user.access_permissions(accessLevelPending).should == {:browse => false, :analyse => false, :download => false}
      user.access_permissions(accessLevelNoAccess).should == {:browse => false, :analyse => false, :download => false}
    end

    it "checks access to restricted datasets" do
      user = User.make

      accessLevelNoAccess,
      accessLevelPending,
      accessLevelBrowse,
      accessLevelAnalyse,
      accessLevelDownload,
      accessLevelAnalyseDownload = [].fill(0, 6) { |i| AccessLevel.make(:b) }

      user.permissions_b.create(:datasetID => accessLevelPending.datasetID, :permissionvalue => 0)
      user.permissions_b.create(:datasetID => accessLevelBrowse.datasetID,
                                :permissionvalue => UserPermissionB::PERMISSION_VALUES[:browse])
      user.permissions_b.create(:datasetID => accessLevelAnalyse.datasetID,
                                :permissionvalue => UserPermissionB::PERMISSION_VALUES[:analyse])
      user.permissions_b.create(:datasetID => accessLevelDownload.datasetID,
                                :permissionvalue => UserPermissionB::PERMISSION_VALUES[:download])
      user.permissions_b.create(:datasetID => accessLevelAnalyseDownload.datasetID,
                                :permissionvalue => UserPermissionB::PERMISSION_VALUES[:analyse] *
                                                    UserPermissionB::PERMISSION_VALUES[:download])

      user.access_permissions(accessLevelNoAccess).should == {:browse => false, :analyse => false, :download => false}
      user.access_permissions(accessLevelPending).should == {:browse => false, :analyse => false, :download => false}
      user.access_permissions(accessLevelBrowse).should == {:browse => true, :analyse => false, :download => false}
      user.access_permissions(accessLevelAnalyse).should == {:browse => true, :analyse => true, :download => false}
      user.access_permissions(accessLevelDownload).should == {:browse => true, :analyse => false, :download => true}
      user.access_permissions(accessLevelAnalyseDownload).should == {:browse => true, :analyse => true, :download => true}
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
