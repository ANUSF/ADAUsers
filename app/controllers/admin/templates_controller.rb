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

  def new
    @template = Template.new
  end

  def create
    @template = Template.new(params[:template])

    if @template.save
      redirect_to admin_templates_path, :notice => "Your template has been created."
    else
      render :new
    end
  end

  def edit
    @template = Template.find(params[:id])
  end

  def update
    @template = Template.find(params[:id])

    if @template.update_attributes(params[:template])
      redirect_to admin_templates_path, :notice => "Your template has been updated."
    else
      render :edit
    end
  end
end
