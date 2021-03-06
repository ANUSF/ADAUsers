class Admin::UsersController < ApplicationController
  before_filter :require_admin
  layout 'ada_admin'


  def index
    redirect_to search_admin_users_path
  end

  def search
    @users = nil
    @institutions_australian_other = User.australian_institutions
    @institutions_non_australian = User.non_australian_institutions
    
    if params.has_key? :search
      @search_query = params[:search][:q]
      case params[:commit]
      when "Search by username"
        @users = User.where("user LIKE ?", "%%#{@search_query}%%")

      when "Search by surname"
        @users = User.where("sname LIKE ?", "%%#{@search_query}%%")

      when "Search by email address"
        @users = User.where("email LIKE ?", "%%#{@search_query}%%")

      when "Search by institution"
        @institution_type = params[:search][:institution_type]
        case params[:search][:institution_type]
        when "Uni"
          @uniid = params[:search][:uniid]
          @users = User.where(:uniid => @uniid)
        when "Dept"
          @departmentid = params[:search][:departmentid]
          @users = User.where(:departmentid => @departmentid)
        when "Other"
          @australian_other = params[:search][:australian_other]
          @users = User.where(:austinstitution => "Other", :institution => @australian_other)
        when "NonAus"
          @non_australian = params[:search][:non_australian]
          @users = User.where("countryid != ? AND institution = ?", User::AUSTRALIA, @non_australian)
        else
          raise "Unknown institution type: #{params[:search][:institution_type]}"
        end

      when "List all users"
        @users = User.scoped

      else
        raise "Unknown search type: #{params[:commit]}"
      end

      # This slows things down massively, but would be faster for listing all results
      #@users = @users.includes(:user_roles, :country, :australian_uni, :australian_gov)

      respond_to do |wants|
        wants.html do
          @paginate = params[:paginate] != '0'
          @users = @users.paginate :page => params[:page], :order => 'user', :per_page => (@paginate ? 30 : @users.count)
        end
        wants.csv do
          render_csv
        end
      end
    end
  end

  def edit
    @user = User.find_by_user(params[:id])

    @datasetsPendingA = @user.permissions_a.pending
    @datasetsAccessibleA = @user.permissions_a.accessible.without_parented_files
    @datasetsPendingB = @user.permissions_b.pending
    @datasetsAccessibleB = @user.permissions_b.accessible.without_parented_files

    @datasetsCatA = AccessLevel.cat_a
    @datasetsCatB = AccessLevel.cat_b
  end

  def update
    @user = UserWithoutValidations.find_by_user(params[:id])
    @user.update_attributes(params[:user])

    @category = nil
    @category = :b if @user.datasets_cat_b_pending_to_grant.present?
    @category = :a if @user.datasets_cat_a_pending_to_grant.present?

    if @category
      flash[:notice] = "Update successful. You may review and edit the confirmation email below before you send it."

      @redirect_to = edit_admin_user_path(@user)
      @datasets = @category == :a ? @user.datasets_cat_a_pending_to_grant : @user.datasets_cat_b_pending_to_grant
      @dataset_descriptions = @datasets.map { |datasetID| AccessLevel.find_by_datasetID(datasetID).dataset_description }.uniq

      locals = {:user => @user, :category => @category, :dataset_descriptions => @dataset_descriptions}
      template = Template.find_by_doc_type_and_name('email', 'study_access_approval')

      @email = Email.new(:from    => Email::DEFAULT_FROM,
                         :to      => @user.email,
                         :subject => render_template_field(template.title, locals),
                         :body    => render_template_field(template.body,  locals))

      render 'admin/emails/new'

    else
      redirect_to edit_admin_user_path(@user), :notice => 'Update successful.'
    end
  end
end
