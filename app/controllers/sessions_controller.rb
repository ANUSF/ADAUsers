class SessionsController < ApplicationController
  layout "session"

  def new
    oidreq = session[:last_oidreq]
    @username = username_for oidreq.identity if oidreq and not oidreq.id_select
    if session[:username]
      flash[:notice] =
        "You are already logged in as #{session[:username]}." +
        " Do not press 'Login' unless you want to end that session."
    end
  end

  def create
    oidreq = session[:last_oidreq]

    if params[:commit] != 'Login'
      reset_session
      if oidreq
        redirect_to oidreq.cancel_url
      else
        redirect_to new_session_url :notice => 'Login cancelled'
      end
    else
      username = if oidreq and not oidreq.id_select
                   username_for oidreq.identity
                 else 
                   params[:session][:username]
                 end
      user = User.find_by_user username
      if user.nil? or user.password != params[:session][:password]
        redirect_to new_session_url, :alert => 'Incorrect password or identity'
      else
        reset_session
        session[:username] = username
        if oidreq
          session[:approvals] = [oidreq.trust_root]
          render_response(positive_response(oidreq, username))
        else
          redirect_to user_url(username), :notice => 'Login successful'
        end
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
