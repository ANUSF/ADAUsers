class UsersController < ApplicationController
  before_filter :require_admin_or_owner, :only => [:show, :change_password, :edit, :change_password, :update]
  before_filter :require_no_user, :only => [:new, :create]


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

  def new
    @user = User.new User.defaults
  end

  def create
    @user = User.new params[:user]
    @user.user = params[:user][:user] # primary key, needs to be set manually
    if @user.save
      redirect_to root_path, :notice => 'Registration successful!'
    else
      flash.now[:alert] = 'Please check the values you filled in.'
      render :new
    end
  end

  def edit
    @user = User.find_by_user(params[:id])
  end

  def change_password
    @user = User.find_by_user(params[:id])
  end

  def update
    # TODO: If the user is editing themselves, do not allow them to update their permissions

    @user = User.find_by_user(params[:id])

    if @user.update_attributes(params[:user])
      flash[:notice] = (params[:commit] == "Submit" ? 'Update successful' : 'Your password has been updated.')
      redirect_to @user
    else
      render (params[:commit] == "Submit" ? :edit : :change_password)
    end
  end


  protected

  def require_admin_or_owner
    @username = params[:id] || params[:username]

    if require_user != false and @username != current_user.user and !current_user.admin?
      redirect_to root_url, :notice => "You may not access another user's details."
      return false
    end
  end

end
