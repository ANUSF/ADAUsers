class Search < ActiveRecord::Base
  set_primary_keys :userId, :query, :date

  belongs_to :user, :class_name => 'User', :primary_key => 'user', :foreign_key => 'userId'

  default_scope order('date ASC')
end
