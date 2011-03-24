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

  has_many :anu_logs, {
    :class_name => "AnuLog",
    :primary_key => :user,
    :foreign_key => :name }

  has_many :searches, {
    :class_name => "Search",
    :primary_key => :user,
    :foreign_key => :userId }

  def permissions(category)
    if category == :a
      self.permissions_a
    elsif category == :b
      self.permissions_b
    else
      raise(ArgumentError, "category must be :a or :b")
    end
  end

  # -- Default attributes to use in the registration form

  def self.defaults
    {
      :country => AUSTRALIA,
      :austinstitution => 'Uni'
    }
  end


  # -- We use some non-database attributes in the registration and edit forms

  attr_writer(:other_australian_affiliation, :other_australian_type,
              :non_australian_affiliation, :non_australian_type)
  def other_australian_affiliation
    @other_australian_affiliation ||
      (country == AUSTRALIA && !['Uni', 'Dept'].include?(austinstitution) && self.institution) ||
      nil
  end
  def other_australian_type
    @other_australian_type ||
      (country == AUSTRALIA && !['Uni', 'Dept'].include?(austinstitution) && self.institutiontype) ||
      nil
  end
  def non_australian_affiliation
    @non_australian_affiliation || (country != AUSTRALIA && self.institution) || nil
  end
  def non_australian_type
    @non_australian_type || (country != AUSTRALIA && self.institutiontype) || nil
  end


  attr_accessor(:datasets_cat_a_to_add,                              :datasets_cat_a_pending_to_grant, :datasets_cat_a_files)
  attr_accessor(:datasets_cat_b_to_add, :datasets_cat_b_permissions, :datasets_cat_b_pending_to_grant, :datasets_cat_b_files)


  # -- Clean up and set derived attributes before creating the user record

  before_create :complete_user_data, :set_derived_fields
  before_update :update_from_attrs, :set_derived_fields

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
  end

  def update_from_attrs
    self.update_role!(@user_role) if @user_role

    self.add_datasets!(self.datasets_cat_a_to_add, :a) if self.datasets_cat_a_to_add
    self.grant_pending_datasets!(self.datasets_cat_a_pending_to_grant, :a) if self.datasets_cat_a_pending_to_grant
    self.update_file_permissions!(self.datasets_cat_a_files, :a) if self.datasets_cat_a_files

    self.add_datasets!(self.datasets_cat_b_to_add, :b, self.datasets_cat_b_permissions) if self.datasets_cat_b_to_add
    self.grant_pending_datasets!(self.datasets_cat_b_pending_to_grant, :b) if self.datasets_cat_b_pending_to_grant
    self.update_file_permissions!(self.datasets_cat_b_files, :b) if self.datasets_cat_b_files
  end

  def set_derived_fields
    self.institution, self.institutiontype, self.uniid, self.departmentid =
      if country == AUSTRALIA
        case austinstitution
        when 'Uni'
          uni = AustralianUni.find(uniid)
          [ uni.Longuniname, "Australian University", uni.id, nil ]
        when 'Dept'
          dept = AustralianGov.find(departmentid)
          [dept.name, dept.type, nil, dept.id]
        else
          [other_australian_affiliation, other_australian_type, nil, nil]
        end
      else
        [non_australian_affiliation, non_australian_type, nil, nil]
      end
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


  # -- The database attribute acsprimember actually refers to whether the user has signed
  #    a general undertaking form, NOT whether the institution with which they are affiliated
  #    is an ACSPRI member. We encapsulate this inconsistency below.

  def signed_undertaking?
    read_attribute(:acsprimember) == 1
  end

  def signed_undertaking
    read_attribute(:acsprimember)
  end

  def signed_undertaking=(signed_undertaking)
    write_attribute(:acsprimember, signed_undertaking)
  end

  def acsprimember
    acsprimember = false

    if self.country == AUSTRALIA
      if self.austinstitution == 'Uni'
        acsprimember = self.australian_uni.acsprimember
      elsif self.austinstitution == 'Dept'
        acsprimember = self.australian_gov.acsprimember
      end
    end

    acsprimember
  end

  def acsprimember=(acsprimember)
    raise "You can't set an institution's ACSPRI membership through a user"
  end
  

  # -- Setters and getters

  def name
    [self.title, self.fname, self.sname].join(' ')
  end

  def affiliation
    if self.country != AUSTRALIA
      self.non_australian_affiliation

    else
      case self.austinstitution
        when 'Uni'
        self.australian_uni.Longuniname

        when 'Dept'
        self.australian_gov.name

        when 'Other'
        self.other_australian_affiliation
      end
    end
  end

  def position_s
    read_attribute(:position) == "Other" ? read_attribute(:otherpd) : read_attribute(:position)
  end

  def type_of_work
    self.action == "Other" ? self.otherwt : self.action
  end

  def sector
    self.austinstitution ? self.austinstitution.sub(/^Uni$/, "University").sub(/^Dept$/, "Government/Research") : nil
  end

  def last_access_time
    log = self.anu_logs.last
    log ? log.date_processed : nil
  end

  def last_search_time
    search = self.searches.last
    search ? search.date : nil
  end

  def num_accesses_in_past(duration=nil)
    logs = self.anu_logs
    logs = logs.where("date_processed > ?", Time.now - duration) unless duration.nil?
    logs.count
  end



  def admin?
    ['administrator', 'publisher'].include? self.user_role
  end

  def user_role
    self.user_roles.first.roleID unless self.user_roles.empty?
  end

  def user_role=(role)
    @user_role = role
  end

  def update_role!(role_id)
    # This lookup is not strictly required, but is included because it validates role_id
    role = RoleEjb.find_by_id!(role_id)

    self.user_roles.clear

    self.user_roles.build(:roleID => role.id)  if  self.new_record?
    self.user_roles.create(:roleID => role.id) if !self.new_record?
  end

  # Add permission to the supplied datasets in the specified category, which may be :a or :b
  def add_datasets!(ids, category, permissions=nil)
    permission_value = 1
    permission_value = permissions.keys.inject(1) { |product, p| product * p.to_i } if permissions

    ids.each do |datasetID|
      permission = self.permissions(category).where(:datasetID => datasetID, :fileID => nil).first
      if permission
        permission.permissionvalue = permission_value
        permission.save!
      else
        self.permissions(category).create(:datasetID => datasetID, :permissionvalue => permission_value)
      end
    end
  end

  def grant_pending_datasets!(ids, category)
    ids.each do |datasetID|
      permission = self.permissions(category).where(:datasetID => datasetID, :fileID => nil, :permissionvalue => 0).first
      permission.update_attributes(:permissionvalue => (category == :a ? 1 : 6))
    end
  end

  # permissions are in the structure: datasetID => fileID => permission('0|1')
  def update_file_permissions!(permissions, category)
    permissions.each_pair do |datasetID, dataset|
      dataset.each_pair do |fileID, permission|
        p = self.permissions(category).find_or_initialize_by_datasetID_and_fileID(datasetID, fileID)

        if permission == '1'
          p.permissionvalue = (category == :a ? 1 : 2)
          p.save!
        else
          p.destroy unless p.new_record?
        end
      end
    end
  end
end
