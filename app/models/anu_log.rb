class AnuLog < ActiveRecord::Base
  establish_connection "#{Rails.env}_logs"
  set_table_name 'anulogs'
  set_primary_key :date_processed

  belongs_to :user, :foreign_key => 'name'

  default_scope order('date_processed')

  # Ruby Objects have a method named 'method', so define an alias for the method attribute of AnuLog
  def method_attr
    read_attribute(:method)
  end
  def method_attr=(method)
    write_attribute(:method, method)
  end
end
