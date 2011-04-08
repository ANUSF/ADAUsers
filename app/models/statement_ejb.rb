class StatementEjb < ActiveRecord::Base
  establish_connection "#{Rails.env}_nesstar"
  set_table_name 'StatementEJB'
  set_primary_key :id

  

end
