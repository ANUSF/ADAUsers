class AnuLog < ActiveRecord::Base
  establish_connection "#{Rails.env}_logs"
  set_table_name 'anulogs'
  set_primary_key :date_processed

  belongs_to :user, :foreign_key => 'name'

  default_scope order('date_processed')
end
