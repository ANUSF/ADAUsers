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

  def new
    @user = User.new User.defaults
  end

  def create
    @user = User.new params[:user]
    if @user.valid?
      flash[:notice] = 'User registration is not yet functional.'
    else
      flash.now[:alert] = 'Please check the values you filled in.'
      render :new
    end
  end
end
