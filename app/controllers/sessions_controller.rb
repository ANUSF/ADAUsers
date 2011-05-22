class SessionsController < ApplicationController
  #TODO these tests may not be sensible when acting as an OpenID provider
  #before_filter :require_no_user, :only => [:new, :create]
  #before_filter :require_user, :only => :destroy

  def new
    oidreq = session[:last_oidreq]
    @username = username_for oidreq.identity if oidreq and not oidreq.id_select
    @username ||= current_user.user if current_user
    @redirect_to = params[:redirect_to]
    show_form = true

    unless session[:username].blank?
      if @username
        flash[:notice] =
          "You are already logged in as #{session[:username]}." +
          " Do not press 'Login' unless you want to end that session."
      elsif oidreq and oidreq.id_select
        show_form = false
        if (session[:approvals] ||= []).include? oidreq.trust_root
          render_response(positive_response(oidreq, session[:username]))
        else
          redirect_to new_decision_path
        end
      end
    end
    render :layout => false if show_form && headless?
  end

  def create
    oidreq = session[:last_oidreq]

    if params[:commit] and params[:commit] != 'Log in'
      reset_session
      if oidreq
        redirect_to oidreq.cancel_url
      else
        redirect_to new_session_url, :notice => 'Login cancelled'
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

        # When a new admin logs in for the first time, we replace their UserEJB token password
        # with their real password as this is required for them to access Nesstar's admin features.
        if user.admin? and user.user_ejb.password == UserEjb::TOKEN_PASSWORD
          user.user_ejb.password = params[:session][:password]
          user.user_ejb.save!
        end

        if oidreq
          session[:approvals] = [oidreq.trust_root]
          render_response(positive_response(oidreq, username))
        else
          @redirect_to = params[:session][:redirect_to]
          @redirect_to = user_url(username) if @redirect_to.nil? or @redirect_to.blank?

          redirect_to @redirect_to, :notice => 'Login successful'
        end
      end
    end
  end

  def destroy
    reset_session

    flash[:notice] = "You have successfully logged out."

    redirect_to params[:return_url] || root_url
  end
end
