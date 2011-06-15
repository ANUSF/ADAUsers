class UsersController < ApplicationController
  before_filter :require_admin_or_owner, :only => [:change_password, :edit, :change_password, :update, :show]
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_api_key, :only => [:role, :details, :access, :privileged]

  def show
    @username = params[:user_id] || params[:username] || params[:id]
    @user = User.find_by_user(@username)
  end

  def discover
    @username = params[:username]

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
      UserMailer.register_email(self, @user, params[:user][:password]).deliver
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
    @token_reset_password = @user.token_reset_password == params[:token] && params[:token]
    # TODO: This var needs to be set by update() on error
  end

  def update
    # TODO: If the user is editing themselves, do not allow them to update their permissions

    @user = User.find_by_user(params[:id])

    if @user.update_attributes(params[:user])
      if params[:commit] == "Submit"
        flash[:notice] = 'Update successful.'
      else
        flash[:notice] = 'Your password has been updated.'
        UserMailer.change_password_email(self, @user, params[:user][:password]).deliver
      end
      redirect_to @user
    else
      render (params[:commit] == "Submit" ? :edit : :change_password)
    end
  end

  def reset_password
    if params[:reset_password]
      if @user = UserWithoutValidations.find_by_email(params[:reset_password][:email])
        @user.token_reset_password = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(16).join
        @user.save!

        UserMailer.reset_password_email(self, @user).deliver

        redirect_to root_path, :notice => 'An email has been sent to you containing instructions to reset your password.'

      else
        flash[:notice] = "That email address was not found."
      end

    elsif params[:token]
      if @user = UserWithoutValidations.find_by_token_reset_password(params[:token])
        # Log the user in and redirect them to the change password page
        reset_session
        session[:username] = @user.user

        redirect_to change_password_user_path(@user, :token => params[:token])

      else
        flash[:notice] = "That reset password link is invalid. Please make sure that the URL you entered is correct."
      end
    end
  end


  ############################################################
  # JSON API
  #
  # TODO: Should we make this more RESTful?
  #

  def role
    @user = User.find_by_user(params[:id])
    render :json => @user.user_role
  end

  def details
    @user = User.find_by_user(params[:id])
    render :json => @user.attributes_api
  end

  # Expects resource to be "datasetID[/fileID]"
  def access
    @user = User.find_by_user(params[:id])
    @datasetID, @fileID = params[:resource].split '/'

    is_restricted = AccessLevel.dataset_is_restricted(@datasetID)
    category = is_restricted ? :b : :a

    permissions = @user.permissions_for_dataset(category, @datasetID, @fileID)

    pv = permissions
      .reject { |e| e.permissionvalue == 0 }
      .inject(0) { |a, e| a == 0 ? e.permissionvalue : a * e.permissionvalue }

    # General datasets have analyse and download permissions if browse access is granted
    if !is_restricted
      pv *= UserPermissionB::PERMISSION_VALUES[:analyse] * UserPermissionB::PERMISSION_VALUES[:download]
    end

    result = {:browse   => pv > 0 && pv % UserPermissionB::PERMISSION_VALUES[:browse] == 0,
              :analyse  => pv > 0 && pv % UserPermissionB::PERMISSION_VALUES[:analyse] == 0,
              :download => pv > 0 && pv % UserPermissionB::PERMISSION_VALUES[:download] == 0}

    render :json => result
  end

  def privileged
    @users = User.privileged
    render :json => @users.map { |user| user.attributes_api }
  end
end
