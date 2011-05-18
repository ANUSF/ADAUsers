class DecisionsController < ApplicationController
  def new
    flash[:notice] = "Do you trust this site with your identity?"
    render :layout => false if headless?
  end

  def create
    oidreq = session.delete :last_oidreq
    session.delete :headless

    if params[:commit] == 'yes'
      (session[:approvals] << oidreq.trust_root).uniq!
      render_response(positive_response(oidreq, session[:username]))
    else
      redirect_to oidreq.cancel_url
    end
  end
end
