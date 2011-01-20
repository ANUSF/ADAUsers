class AustralianGov < ActiveRecord::Base
  class Type
    def initialize(rec)
      @type = rec[:type]
    end

    def name
      @type || ''
    end

    def members
      @type.blank? ? [AustralianGov.new] : AustralianGov.where(:type => @type)
    end
  end

  set_table_name 'agenciesdept'
  set_inheritance_column false

  def self.types
    scoped.group(:type).select(:type).map { |x| Type.new(x) }
  end
end
