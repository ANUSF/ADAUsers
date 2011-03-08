require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Modify access to accessible datasets", %q{
  In order to manage user access to data
  As an administrator
  I want to adjust permissions for accessible datasets
} do

  before(:each) do
    @admin = User.find_by_user("administrator") || User.make(:administrator, :user => "administrator")
    log_in_as(@admin) unless logged_in?

    @user = User.make(:user => 'tester')
  end


  scenario "viewing available datasets" do
    # Make some datasets
    ['A', 'G', 'B', 'S'].each do |accessLevel|
      2.times { AccessLevel.make(:accessLevel => accessLevel) }
    end

    visit "/users/tester/edit"
    
    # -- Unrestricted datasets
    accessLevelsA = AccessLevel
      .where(:accessLevel => ['A', 'G'], :fileID => nil)
      .where("datasetID NOT IN (SELECT datasetID FROM accesslevel al2 WHERE al2.accesslevel in ('B', 'S') and al2.fileID is NULL)")
      .order('datasetID ASC')

    accessLevelsA.each do |accessLevel|
      find("select#user_datasets_cat_a_to_add").should have_content(accessLevel.dataset_description)
    end


    # -- Restricted datasets
    accessLevelsB = AccessLevel.where(:accessLevel => ['B', 'S'], :fileID => nil).order('datasetID ASC')

    accessLevelsB.each do |accessLevel|
      find("select#user_datasets_cat_b_to_add").should have_content(accessLevel.dataset_description)
    end
  end


  scenario "adding a category A dataset" do
    datasets = make_datasets(:a)
    
    visit "/users/tester/edit"
    
    # Submit the form with these two datasets
    find("select#user_datasets_cat_a_to_add").select(datasets[:present].dataset_description)
    find("select#user_datasets_cat_a_to_add").select(datasets[:absent].dataset_description)
    find("#category_a").click_button("Add dataset(s)")

    # Ensure that both are now present, and without any duplicate rows
    datasets.each_value do |dataset|
      @user.permissions_a.where(:datasetID => dataset.datasetID).count.should == 1
      @user.permissions_a.where(:datasetID => dataset.datasetID, :permissionvalue => 1).should be_present
    end
  end


  scenario "adding a category B dataset" do
    datasets = make_datasets(:b)
    
    visit "/users/tester/edit"
    
    # Build an array of valid combinations of the three permissions
    permissions = [[], [:analyse], [:download], [:analyse, :download]]

    permissions.each do |permission|
      find("select#user_datasets_cat_b_to_add").select(datasets[:present].dataset_description)
      find("select#user_datasets_cat_b_to_add").select(datasets[:absent].dataset_description)

      # Select permission(s)
      permission.each do |p|
        find("#category_b").check(p.to_s.capitalize)
      end

      find("#category_b").click_button("Add/Update dataset(s)")
    
      # Ensure that both datasets are now present, and without any duplicate rows
      permission_value = UserPermissionB.permission_value(permission)
      datasets.each_value do |dataset|
        @user.permissions_b.where(:datasetID => dataset.datasetID).count.should == 1
        @user.permissions_b.where(:datasetID => dataset.datasetID, :permissionvalue => permission_value).should be_present
      end
    end
  end


  scenario "viewing added datasets" do
    [:a, :b].each do |category|
      # Start with two datasets - one that's already been added, and one that hasn't
      accessLevels = {}
      accessLevels[:present] = AccessLevel.make(category)
      accessLevels[:pending] = AccessLevel.make(category)
      accessLevels[:absent] = AccessLevel.make(category)

      @user.permissions(category).create(:datasetID => accessLevels[:present].datasetID, :permissionvalue => 1)
      @user.permissions(category).create(:datasetID => accessLevels[:pending].datasetID, :permissionvalue => 0)

      @user.permissions(category).where(:datasetID => accessLevels[:present].datasetID).should_not be_empty
      @user.permissions(category).where(:datasetID => accessLevels[:pending].datasetID).should_not be_empty
      @user.permissions(category).where(:datasetID => accessLevels[:absent].datasetID).should be_empty

      visit "/users/tester/edit"

      # dataset => table_name => should_be_present
      # eg. present => pending => false
      expected_results = {:present => {:accessible => true, :pending => false},
                          :pending => {:accessible => false, :pending => true},
                          :absent =>  {:accessible => false, :pending => false}}

      expected_results.each_pair do |dataset, expected_tables|
        expected_tables.each_pair do |table, should_be_present|
          find("#category_#{category} table##{table}").has_content?(accessLevels[dataset].datasetID).should == should_be_present
          find("#category_#{category} table##{table}").has_content?(accessLevels[dataset].datasetname).should == should_be_present
        end
      end
    end

    # We should see the revoke action for cat A datasets, but not for cat B
    find("#category_a table#accessible").should     have_content("Revoke Permission")
    find("#category_b table#accessible").should_not have_content("Revoke Permission")
  end


  scenario "viewing category B dataset permissions" do
    accessLevel = AccessLevel.make(:b)
    permission = @user.permissions_b.create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)

    [[:browse], [:analyse], [:download], [:analyse, :download]].each do |permissions|
      permission_value = UserPermissionB.permission_value(permissions)

      permission.permissionvalue = permission_value
      permission.save!

      visit "/users/tester/edit"

      find("#category_b table#accessible").should have_content(UserPermissionB::PERMISSION_VALUE_S[permission_value])
    end
  end


  scenario "deleting an accessible or pending dataset" do
    [:a, :b].each do |category|
      accessLevels = {}
      accessLevels[:accessible] = AccessLevel.make(category)
      accessLevels[:pending] = AccessLevel.make(category)

      @user.permissions(category).create(:datasetID => accessLevels[:accessible].datasetID, :permissionvalue => 1)
      @user.permissions(category).create(:datasetID => accessLevels[:pending].datasetID, :permissionvalue => 0)

      @user.permissions(category).where(:datasetID => accessLevels[:accessible].datasetID).should_not be_empty
      @user.permissions(category).where(:datasetID => accessLevels[:pending].datasetID).should_not be_empty

      # When I go to the user edit page
      # Then I should see the accessible dataset in the table
      # When I click on the image link for removing the accessible dataset
      # Then I should not see the accessible dataset in the table

      accessLevels.each_pair do |dataset, accessLevel|
        visit "/users/tester/edit"
        find("#category_#{category} table##{dataset}").should have_content(accessLevels[dataset].datasetID)
        find("#category_#{category} table##{dataset} a:has(img[alt='delete'])").click()
        page.should_not have_selector("#category_#{category} table##{dataset}")
      end
    end
  end


  scenario "revoking permission to a category A accessible dataset" do
    # Given that I have an accessible dataset with a file
    accessLevel = AccessLevel.make
    accessLevelFile = AccessLevel.make(:with_fileContent, :datasetID => accessLevel.datasetID)
    @user.permissions_a.create(:datasetID => accessLevel.datasetID, :permissionvalue => 1)
    @user.permissions_a.create(:datasetID => accessLevel.datasetID, :permissionvalue => 1, :fileID => accessLevelFile.fileID)

    # And I can see it in the accessible table, but not the pending table
    visit "/users/tester/edit"
    find("#category_a table#accessible").should have_content(accessLevel.datasetID)
    page.should_not have_selector("#category_a table#pending")

    # And I can see the file details in the table
    ['File Content', 'File ID', 'Access Level', 'Grant Download'].each do |column_name|
      find("#category_a table#accessible").should have_content(column_name)
    end

    # When I click on the image link "revoke"
    find("#category_a table#accessible a:has(img[alt='revoke'])").click()

    # Then I should not have permission to access the dataset, but I should do for the file
    @user.permissions_a.where(:datasetID => accessLevel.datasetID, :fileID => nil).should be_empty
    @user.permissions_a.where(:datasetID => accessLevel.datasetID, :fileID => accessLevelFile.fileID).should_not be_empty

    # And I should see the dataset in the table without the revoke button
    find("#category_a table#accessible").should have_content(accessLevel.datasetID)
    page.should_not have_selector("#category_a table#accessible img[alt='revoke']")

    # And I should see the file details in the table
    ['File Content', 'File ID', 'Access Level', 'Grant Download'].each do |column_name|
      find("#category_a table#accessible").should have_content(column_name)
    end
  end


  # -- Support functions

  # Make two datasets - one that's already been added, and one that hasn't
  def make_datasets(category)
    accessLevelPresent = AccessLevel.make(category)
    accessLevelAbsent = AccessLevel.make(category)
    @user.permissions(category).create(:datasetID => accessLevelPresent.datasetID, :permissionvalue => 1)
    
    @user.permissions(category).where(:datasetID => accessLevelPresent.datasetID).should_not be_empty
    @user.permissions(category).where(:datasetID => accessLevelAbsent.datasetID).should be_empty

    {:present => accessLevelPresent, :absent => accessLevelAbsent}
  end
end
