class User < ActiveRecord::Base
  set_table_name 'userdetails'
  set_primary_key 'user'

  def after_find
    readonly!
  end
end
