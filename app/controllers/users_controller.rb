class UsersController < ApplicationController
  before_filter :require_admin_or_owner, :only => [:change_password, :edit, :change_password, :update]
  before_filter :require_no_user, :only => [:new, :create]


  def show
    @username = params[:user_id] || params[:username] || params[:id]
    @user = User.find_by_user(@username)

    respond_to do |format|
      format.html do
        require_admin_or_owner
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
      UserMailer.register_email(@user, params[:user][:password]).deliver
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
      if params[:commit] == "Submit"
        flash[:notice] = 'Update successful.'
      else
        flash[:notice] = 'Your password has been updated.'
        UserMailer.change_password_email(@user, params[:user][:password]).deliver
      end
      redirect_to @user
    else
      render (params[:commit] == "Submit" ? :edit : :change_password)
    end
  end

  def reset_password
    if params[:reset_password]
      @user = User.find_by_email(params[:reset_password][:email])
      new_password = (('a'..'z').to_a + (0..9).to_a).sample(8).join
      @user.change_password! new_password
      @user.save!

      UserMailer.reset_password_email(@user, new_password).deliver

      redirect_to root_path, :notice => 'Your username and a new password have been emailed to you.'
    end
  end


  ############################################################
  # JSON API

  def role
    @user = User.find_by_user(params[:id])
    render :json => @user.user_role
  end

  def details
    @user = User.find_by_user(params[:id])
    render :json => @user
  end

  # Expects resource to be "datasetID[/fileID]"
  def access
    @user = User.find_by_user(params[:id])
    @datasetID, @fileID = params[:resource].split '/'

    is_restricted = AccessLevel.dataset_is_restricted(datasetID)
    category = is_restricted ? :b : :a

    permissions = @user.permissions_for_dataset(category, @datasetID, @fileID)

    pv = permissions
      .reject { |e| e.permissionvalue == 0 }
      .inject(0) { |a, e| a == 0 ? e.permissionvalue : a * e.permissionvalue }

    result = {:browse   => pv > 0 && pv % UserPermissionB::PERMISSION_VALUES[:browse] == 0,
              :analyse  => pv > 0 && pv % UserPermissionB::PERMISSION_VALUES[:analyse] == 0,
              :download => pv > 0 && pv % UserPermissionB::PERMISSION_VALUES[:download] == 0}

    render :json => result
  end
end
