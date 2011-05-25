class Template < ActiveRecord::Base
  validates_presence_of :type, :name
  validates_uniqueness_of :name, :scope => :type
end
