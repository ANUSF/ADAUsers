class DecisionsController < ApplicationController
  layout "session"

  def new
    flash[:notice] = "Do you trust this site with your identity?"
    @oidreq = session[:last_oidreq]
  end

  def create
    oidreq = session[:last_oidreq]
    session[:last_oidreq] = nil

    if params[:commit] == 'yes'
      (session[:approvals] << oidreq.trust_root).uniq!
      render_response(positive_response(oidreq, session[:username]))
    else
      redirect_to oidreq.cancel_url
    end
  end
end
