class SessionsController < ApplicationController
  layout "session"

  def new
    @oidreq = session[:last_oidreq]
    @username = username_for @oidreq.identity unless @oidreq.id_select
  end

  def create
    oidreq = session[:last_oidreq]

    if params[:result] != 'Login'
      reset_session
      redirect_to oidreq.cancel_url
    else
      username = if oidreq.id_select
                   params[:username]
                 else
                   username_for oidreq.identity
                 end
      user = User.find_by_user username
      if user.nil? or user.password != params[:password]
        redirect_to new_session_url, :alert => 'Incorrect password or identity'
      else
        reset_session
        session[:username] = username
        session[:approvals] = [oidreq.trust_root]
        render_response(positive_response(oidreq, username))
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
