class UsersController < ApplicationController
  def show
    respond_to do |format|
      format.html { response.headers['X-XRDS-Location'] = xrds_user_url }
      format.xrds { redirect_to xrds_user_url }
    end
  end
end
