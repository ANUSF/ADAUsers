class DecisionsController < ApplicationController
  def new
    if session[:last_oidreq]
      flash[:notice] = "Do you trust this site with your identity?"
      render :layout => 'headless' if headless?
    else
      redirect_to root_url, :notice => 'No current OpenID request'
    end
  end

  def create
    oidreq = session.delete :last_oidreq
    session.delete :headless

    if params[:commit] == 'yes'
      add_trusted oidreq.trust_root
      render_response(positive_response(oidreq, session[:username]))
    else
      if oidreq
        redirect_to oidreq.cancel_url
      else
        redirect_to root_url, :notice => 'No current OpenID request.'
      end
    end
  end

  private

  def add_trusted(root)
    session[:approvals] ||= []
    session[:approvals] << root unless session[:approvals].include? root
  end
end
