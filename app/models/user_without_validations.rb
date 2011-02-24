class UserWithoutValidations < ActiveRecord::Base
  AUSTRALIA = Country.find_by_Countryname('Australia')

  set_table_name 'userdetails'
  set_primary_key :user

  belongs_to :country,        :foreign_key => 'countryid'
  belongs_to :australian_uni, :foreign_key => 'uniid'
  belongs_to :australian_gov, :foreign_key => 'departmentid'

  has_one :user_ejb, {
    :primary_key => :user,
    :foreign_key => :id,
    :dependent => :destroy }

  has_many :user_roles, {
    :primary_key => :user,
    :foreign_key => :id,
    :dependent => :destroy }

  has_many :permissions_a, {
    :class_name => 'UserPermissionA',
    :primary_key => :user,
    :foreign_key => :userID,
    :dependent => :destroy }

  has_many :permissions_b, {
    :class_name => 'UserPermissionB',
    :primary_key => :user,
    :foreign_key => :userID,
    :dependent => :destroy }

  # -- Default attributes to use in the registration form

  def self.defaults
    {
      :country => AUSTRALIA,
      :austinstitution => 'Uni'
    }
  end

  # -- We use some non-database attributes in the registration form

  attr_accessor(:other_australian_affiliation, :other_australian_type,
                :non_australian_affiliation, :non_australian_type)

  attr_accessor(:datasets_cat_a_to_add, :datasets_cat_a_pending_to_grant, :datasets_cat_a_files)

  # -- Clean up and set derived attributes before creating the user record

  before_create :complete_user_data
  before_update :update_from_attrs

  def complete_user_data
    self.dateregistered = Date.today.to_s

    self.user_roles << UserRole.new(
      :roleID => 'affiliateusers',
      :rolegroup => '')

    self.user_ejb = UserEjb.new(
      :comment => 'registered user',
      :creationDate => dateregistered,
      :label => 'registered user',
      :modificationDate => dateregistered,
      :password => password,
      :active => 1)

    self.institution, self.institutiontype, self.uniid, self.departmentid,
    self.acsprimember =
      if country == AUSTRALIA
        case austinstitution
        when 'Uni'
          uni = AustralianUni.find(uniid)
          [ uni.Longuniname,
            "Australian University", uni.id, nil, uni.acsprimember ]
        when 'Dept'
          dept = AustralianGov.find(departmentid)
          [dept.name, dept.type, nil, dept.id, dept.acsprimember]
        else
          [other_australian_affiliation, other_australian_type, nil, nil, 0]
        end
      else
        [non_australian_affiliation, non_australian_type, nil, nil, 0]
      end
  end

  def update_from_attrs
    self.update_role! @user_role if @user_role
    self.add_datasets! self.datasets_cat_a_to_add if self.datasets_cat_a_to_add
    self.grant_pending_datasets! self.datasets_cat_a_pending_to_grant if self.datasets_cat_a_pending_to_grant
    self.update_file_permissions! self.datasets_cat_a_files if self.datasets_cat_a_files
  end

  # -- Option lists to use in the registration form

  def title_options
    ['Mr', 'Mrs', 'Miss', 'Ms', 'Dr' ]
  end

  def position_options
    [ "Undergraduate student",
      [ "PhD/Postgraduate student", "Postgraduate student" ],
      [ "Other student (e.g. secondary school/high school)", "Other student" ],
      [ "Lecturer/teacher", "Lecturer" ],
      "Researcher",
      "Research Assistant",
      [ "Personal user (no institutional, " +
        "company or organizational affiliation)", "Personal" ],
      "Other"
    ]
  end

  def action_options
    [ [ "Thesis or coursework", "coursework" ],
      "Teaching",
      "Pure research",
      "Research Consultancy",
      [ "Government research", "Government" ],
      [ "Commercial research", "Commercial" ],
      [ "Personal interest", "Personal" ],
      "Other"
    ]
  end

  def austinstitution_options
    [ ['University', 'Uni'], ['Government/Research', 'Dept'], 'Other' ]
  end

  def other_aust_inst_types
    [ "Educational institution",
      "Federal government department",
      "Federal government agency",
      "State government",
      "Media",
      "Not for profit organization",
      "Private company",
      "None - personal user"
    ]
  end

  def non_aust_inst_types
    [ "Non-Australian educational institution",
      "Central or local government",
      "Media",
      "Not for profit organization",
      "Private company",
      "None - personal user",
      "Other"
    ]
  end


  # -- Setters and getters

  def acsprimember?
    read_attribute(:acsprimember) == 1
  end

  def user_role
    self.user_roles.first.roleID unless self.user_roles.empty?
  end

  def user_role=(role)
    @user_role = role
  end

  def update_role!(role_id)
    # This lookup is not strictly required, but is performed because it validates role_id
    role = RoleEjb.find_by_id!(role_id)

    self.user_roles.clear

    self.user_roles.build(:roleID => role.id)  if  self.new_record?
    self.user_roles.create(:roleID => role.id) if !self.new_record?
  end

  def add_datasets!(ids)
    # TODO: Differenciate between cat A and B datasets, and add them to the correct permissions table
    ids.each do |datasetID|
      if self.permissions_a.where(:datasetID => datasetID, :fileID => nil).empty?
        self.permissions_a.create(:datasetID => datasetID, :permissionvalue => 1)
      end
    end
  end

  def grant_pending_datasets!(ids)
    ids.each do |datasetID|
      permission = self.permissions_a.where(:datasetID => datasetID, :fileID => nil, :permissionvalue => 0).first
      permission.update_attributes(:permissionvalue => 1)
    end
  end

  # permissions are in the structure: datasetID => fileID => permission('1'|'0')
  def update_file_permissions!(permissions)
    permissions.each_pair do |datasetID, dataset|
      dataset.each_pair do |fileID, permission|
        p = self.permissions_a.find_or_initialize_by_datasetID_and_fileID(datasetID, fileID)

        if permission == '1'
          p.permissionvalue = 1
          p.save!
        else
          p.destroy unless p.new_record?
        end
      end
    end
  end
end
