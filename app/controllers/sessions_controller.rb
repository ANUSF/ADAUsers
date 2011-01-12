class SessionsController < ApplicationController
  layout "session"

  def new
    # TODO handle oidreq.id_select == true
    @oidreq = session[:last_oidreq]
  end

  def create
    oidreq = session[:last_oidreq]
    reset_session

    if params[:result] != 'Login'
      redirect_to oidreq.cancel_url
    else
      session[:username] = username_for oidreq.identity
      session[:approvals] = [oidreq.trust_root]
      render_response(positive_response(oidreq, oidreq.identity))
    end
  end

  def destroy
    reset_session
    if params[:return_url]
      redirect_to params[:return_url]
    else
      render :text => "Successfully logged out."
    end
  end
end
