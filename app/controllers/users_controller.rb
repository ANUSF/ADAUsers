class UsersController < ApplicationController
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
end
