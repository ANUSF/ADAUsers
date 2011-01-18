class User < ActiveRecord::Base
  set_table_name 'userdetails'
  set_primary_key 'user'

  attr_accessor :email_verify

  # def after_find; readonly! end
end
