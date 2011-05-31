class Email
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :from, :to, :subject, :body

  validates_presence_of :subject, :body

  def initialize(attrs={})
    attrs.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
