class DecisionsController < ApplicationController
  def new
    if session[:last_oidreq]
      site = session[:last_oidreq].trust_root
      flash[:notice] = "Do you trust the site at #{site} with your identity?"
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
        if oidreq.immediate
          render_response(oidreq.answer(false, root_url))
        else
          redirect_to oidreq.cancel_url
        end
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
