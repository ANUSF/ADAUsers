class UsersController < ApplicationController
  layout 'registration'

  def index
    render :search
  end

  def show
    respond_to do |format|
      format.html do
        response.headers['X-XRDS-Location'] = xrds_user_url
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
        @users = User.where("user LIKE ?", "%%#{params[:search][:q]}%%")

      when "Search by email address"
        @users = User.where("email LIKE ?", "%%#{params[:search][:q]}%%")

      when "List all users"
        @users = User
      end

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

    # Fetch the datasets, and set the user on these objects so that calls
    # to UserPermissionX.user_has_access from the view will succeed
    @datasetsPendingA = @user.permissions_a.pending.select("DISTINCT(datasetID)").map {|p| p.tap { p.user = @user } }
    @datasetsAccessibleA = @user.permissions_a.accessible.select("DISTINCT(datasetID)").map {|p| p.tap { p.user = @user } }
    @datasetsPendingB = @user.permissions_b.pending.select("DISTINCT(datasetID)").map {|p| p.tap { p.user = @user } }
    @datasetsAccessibleB = @user.permissions_b.accessible.select("DISTINCT(datasetID)").map {|p| p.tap { p.user = @user } }

    @datasetsCatA = AccessLevel.cat_a
  end

  def update
    @user = UserWithoutValidations.find_by_user(params[:id])
    @user.update_attributes(params[:user])
    redirect_to edit_user_path(@user)
  end
end
