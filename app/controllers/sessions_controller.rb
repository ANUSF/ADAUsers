class SessionsController < ApplicationController
  layout "session"

  def new
    @oidreq = session[:last_oidreq]
    if @oidreq.id_select
      nil
    end
  end

  def create
    oidreq = session[:last_oidreq]

    if params[:result] != 'Login'
      reset_session
      redirect_to oidreq.cancel_url
    else
      username = username_for oidreq.identity
      user = User.find_by_user username
      if user.nil? or user.password != params[:password]
        redirect_to new_session_url, :alert => 'Incorrect password or identity'
      else
        reset_session
        session[:username] = username_for oidreq.identity
        session[:approvals] = [oidreq.trust_root]
        render_response(positive_response(oidreq))
      end
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
