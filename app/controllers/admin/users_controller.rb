class Admin::UsersController < ApplicationController
  before_filter :require_admin


  def index
    redirect_to search_admin_users_path
  end

  def search
    @users = nil
    
    if params.has_key? :search
      @search_query = params[:search][:q]
      case params[:commit]
      when "Search by username"
        @users = User.where("user LIKE ?", "%%#{@search_query}%%")

      when "Search by email address"
        @users = User.where("email LIKE ?", "%%#{@search_query}%%")

      when "List all users"
        @users = User.scoped
      end

      # This slows things down massively, but would be faster for listing all results
      #@users = @users.includes(:user_roles, :country, :australian_uni, :australian_gov)

      @paginate = params[:paginate] != '0'
      @users = @users.paginate :page => params[:page], :order => 'user', :per_page => (@paginate ? 30 : @users.count)
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
    UserWithoutValidations.find_by_user(params[:id])
    @user.update_attributes(params[:user])
    redirect_to admin_edit_user_path(@user), :notice => 'Update successful'
  end

end
