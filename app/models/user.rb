class User < ActiveRecord::Base
  AUSTRALIA = Country.find_by_Countryname('Australia')

  set_table_name 'userdetails'

  belongs_to :country, :foreign_key => 'countryid'
  belongs_to :australian_uni, :foreign_key => 'uniid'
  belongs_to :australian_gov, :foreign_key => 'departmentid'

  # -- Default attributes to use in the registration form

  def self.defaults
    {
      :country => AUSTRALIA,
      :austinstitution => 'Uni'
    }
  end

  # -- We use some non-database attributes in the registration form

  attr_accessor (:email_confirmation,
                 :other_australian_affiliation, :other_australian_type,
                 :non_australian_affiliation, :non_australian_type)

  # -- Validations go here:

  validates :user, {
    :presence => {
      :message => 'please enter a user name' },
    :uniqueness => {
      :message => 'this user name already exists' },
    :format => {
      :with => /\A[\w\.-]*\z/,
      :message =>
      'please use only letters, digits, hyphens, underscores and dots' }}

  validates :fname, {
    :presence => {
      :message => 'please enter your first name' }}

  validates :sname, {
    :presence => {
      :message => 'please enter your last name' }}

  validates :email, {
    :presence => {
      :message => 'please enter your email address' },
    :uniqueness => {
      :message => 'this email address is already being used',
      :unless => lambda { |rec| rec.email.blank? }},
    :format => {
      :with => /\A([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})?\Z/i,
      :message => 'this email address does not look valid' },
    :confirmation => {
      :message => 'please ensure this email address matches the one below ' }
    }

  validates :position, {
    :presence => {
      :message => 'please select one' }}

  validates :otherpd, {
    :presence => {
      :message => 'please enter your position',
      :if => lambda { |rec| rec.position == "Other" }}}

  validates :action, {
    :presence => {
      :message => 'please select one' }}

  validates :otherwt, {
    :presence => {
      :message => 'please enter your type of work',
      :if => lambda { |rec| rec.action == "Other" }}}

  validates :country, {
    :presence => {
      :message => 'please select your country' }}

  validates :austinstitution, {
    :presence => {
      :message => 'please select one',
      :if => lambda { |rec| rec.country == AUSTRALIA }}}

  validates :australian_uni, {
    :presence => {
      :message => 'please select one',
      :if => lambda { |rec|
        rec.country == AUSTRALIA and rec.austinstitution == 'Uni' }}}

  validates :australian_gov, {
    :presence => {
      :message => 'please select one',
      :if => lambda { |rec|
        rec.country == AUSTRALIA and rec.austinstitution == 'Dept' }}}

  validates :other_australian_affiliation, {
    :presence => {
      :message => 'please enter an institution',
      :if => lambda { |rec|
        rec.country == AUSTRALIA and rec.austinstitution == 'Other' }}}

  validates :other_australian_type, {
    :presence => {
      :message => 'please select one',
      :if => lambda { |rec|
        rec.country == AUSTRALIA and rec.austinstitution == 'Other' }}}

  validates :non_australian_affiliation, {
    :presence => {
      :message => 'please enter an institution',
      :if => lambda { |rec| rec.country != AUSTRALIA }}}

  validates :non_australian_type, {
    :presence => {
      :message => 'please select one',
      :if => lambda { |rec| rec.country != AUSTRALIA }}}


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
end
