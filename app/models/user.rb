class User < UserWithoutValidations
  attr_accessor :password_old

  # -- Validations for attributes available in the registration form go here:

  validates :user, {
    :presence => {
      :message => 'please enter a user name' },
    :uniqueness => {
      :message => 'this user name already exists' },
    :format => {
      :with => /\A[\w\.-]*\z/,
      :message =>
      'please use only letters, digits, hyphens, underscores and dots' }}

  validates :password, {
    :presence => {
      :message => 'please enter a password' },
    :length => {
      :minimum => 6,
      :unless => lambda { |rec| rec.password.blank? },
      :message => 'your password must contain at least 6 characters' },
    :confirmation => {
      :message => 'please ensure passwords match' }}

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
      :message => 'please ensure email addresses match' }
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


  # -- Other validations:

  validates_each :password_old, :if => lambda { |rec| rec.password_changed? and !rec.new_record? } do |rec, attr, value|
    rec.errors.add(attr, 'password does not match') if value != rec.password_was
  end


  # -- Setters and getters

  def change_password!(new_password)
    self.password_old = self.password_was
    self.password = new_password
    save!
  end
end
