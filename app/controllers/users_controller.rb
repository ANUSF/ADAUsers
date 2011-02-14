class UsersController < ApplicationController
  layout 'registration'

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

      @users = @users.paginate :page => params[:page], :order => 'user'
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
  end

  def update
    @user = User.find_by_user(params[:id])

    if @user.update_attributes(params[:user])
      flash[:notice] = "That user has been updated."
      redirect_to edit_user_path(@user)
    else
      logger.debug "Error updating: #{@user.errors.inspect}."
      render :action => "edit"
    end

  end
end
