class Admin::TemplatesController < ApplicationController
  before_filter :require_admin
  layout 'ada_admin'

  def index
    templates = Template.all
    @template_groups = {}

    templates.each do |t|
      @template_groups[t.doc_type] = [] unless @template_groups.has_key? t.doc_type
      @template_groups[t.doc_type] << t
    end
  end
end
