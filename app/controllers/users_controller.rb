class UsersController < ApplicationController
  before_filter :require_admin, :only => [:index, :search]
  before_filter :require_admin_or_owner, :only => [:show, :edit, :update]
  before_filter :require_no_user, :only => [:new, :create]


  def index
    render :search
  end

  def show
    @user = User.find_by_user(@username)

    respond_to do |format|
      format.html do
        response.headers['X-XRDS-Location'] = xrds_user_url(@username)
      end
      format.xrds do
        render :text => render_xrds(OpenID::OPENID_2_0_TYPE,
                                    OpenID::OPENID_1_0_TYPE,
                                    OpenID::SREG_URI        )
      end
    end
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

  def new
    @user = User.new User.defaults
  end

  def create
    @user = User.new params[:user]
    @user.user = params[:user][:user] # primary key, needs to be set manually
    if @user.save
      flash[:notice] = 'Registration successful!'
    else
      flash.now[:alert] = 'Please check the values you filled in.'
      render :new
    end
  end

  def edit
    @user = User.find_by_user(params[:id])

    if current_user.admin?
      @datasetsPendingA = @user.permissions_a.pending
      @datasetsAccessibleA = @user.permissions_a.accessible.without_parented_files
      @datasetsPendingB = @user.permissions_b.pending
      @datasetsAccessibleB = @user.permissions_b.accessible.without_parented_files

      @datasetsCatA = AccessLevel.cat_a
      @datasetsCatB = AccessLevel.cat_b
    end
  end

  def update
    # TODO: If the user is editing themselves, do not allow them to update their permissions
    #       Also, use validations in this case, and display errors if there are some any

    @user = UserWithoutValidations.find_by_user(params[:id])
    @user.update_attributes(params[:user])
    redirect_to edit_user_path(@user), :notice => 'Update successful'
  end



  def require_admin_or_owner
    @username = params[:id] || params[:username]

    if require_user != false and @username != current_user.user and !current_user.admin?
      redirect_to root_url, :notice => "You may not access another user's details."
      return false
    end
  end

end
