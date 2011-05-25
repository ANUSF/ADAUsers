class Admin::DocTemplatesController < ApplicationController
  before_filter :require_admin
  layout 'ada_admin'

  def index
    templates = DocTemplate.all
    @template_groups = {}

    templates.each do |t|
      @template_groups[t.doc_type] = [] unless @template_groups.has_key? t.doc_type
      @template_groups[t.doc_type] << t
    end
  end

  def new
    @template = DocTemplate.new
  end

  def create
    @template = DocTemplate.new(params[:doc_template])

    if @template.save
      redirect_to admin_doc_templates_path, :notice => "Your template has been created."
    else
      render :new
    end
  end

  def edit
    @template = DocTemplate.find(params[:id])
  end

  def update
    @template = DocTemplate.find(params[:id])

    if @template.update_attributes(params[:doc_template])
      redirect_to admin_doc_templates_path, :notice => "Your template has been updated."
    else
      render :edit
    end
  end

  def destroy
    @template = DocTemplate.find(params[:id])
    @template.destroy
    redirect_to admin_doc_templates_path, :notice => "Your template has been deleted."
  end
end
