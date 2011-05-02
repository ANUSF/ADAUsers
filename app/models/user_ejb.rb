class UserEjb < ActiveRecord::Base
  set_table_name 'UserEJB'

  belongs_to :user, :primary_key => :user, :foreign_key => :id

  TOKEN_PASSWORD = 'tokenpwd'
end
