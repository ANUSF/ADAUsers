# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ADAUsers::Application.initialize!


# By default, the MysqlAdapter will consider all columns of type tinyint(1)
# as boolean. Nesstar uses tinyint(1) fields to store small integers, so
# we disable that functionality here.
ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans = false
