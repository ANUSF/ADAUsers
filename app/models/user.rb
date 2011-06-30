class User < UserWithoutValidations
  attr_accessor :password_old, :token_reset_password_confirmation

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

  # Provides appropriate security when changing the user's password
  # If changing the password via the change password form, the user must enter their old password correctly.
  # If changing their password via the reset password process, the user must have used a link with a correct
  # reset password token.
  validate :if => lambda { |user| user.password_changed? and !user.new_record? } do |user|
    if user.token_reset_password_confirmation.present?
      if user.token_reset_password_was != user.token_reset_password_confirmation
        user.errors[:base] << 'password reset token is invalid'
      end

    elsif (HASH_PASSWORDS and Password.new(user.password_was) != user.password_old) or
        (!HASH_PASSWORDS and user.password_was != user.password_old)
      user.errors.add(:password_old, 'password does not match')
    end
  end
end
