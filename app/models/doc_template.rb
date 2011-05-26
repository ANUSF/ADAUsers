class Template < ActiveRecord::Base
  validates_presence_of :doc_type, :name
  validates_uniqueness_of :name, :scope => :doc_type

  default_scope order('doc_type, name')

  DOC_TYPES = ['page', 'email']
end
