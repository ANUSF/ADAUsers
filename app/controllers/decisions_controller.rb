class DecisionsController < ApplicationController
  def new
    flash[:notice] = "Do you trust this site with your identity?"
    render :layout => 'headless' if headless?
  end

  def create
    oidreq = session.delete :last_oidreq
    session.delete :headless

    if params[:commit] == 'yes'
      add_trusted oidreq.trust_root
      render_response(positive_response(oidreq, session[:username]))
    else
      redirect_to oidreq.cancel_url
    end
  end

  private

  def add_trusted(root)
    session[:approvals] ||= []
    session[:approvals] << root unless session[:approvals].include? root
  end
end
