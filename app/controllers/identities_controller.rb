require "openid"
require "openid/consumer/discovery"


class IdentitiesController < ApplicationController
  include OpenID::Server
  layout nil

  def index
    begin
      oidreq = server.decode_request(params)
    rescue ProtocolError => e
      render :text => "Invalid OpenID request: #{e.to_s}", :status => 500
      return
    end

    if not oidreq.kind_of?(CheckIDRequest)
      render_response(server.handle_request(oidreq))
    elsif oidreq.immediate
      render_response(oidreq.answer(false, index_url))
    elsif is_logged_in_as(oidreq.identity) and not oidreq.id_select
      if (session[:approvals] || []).include? oidreq.trust_root
        render_response(positive_response(oidreq, oidreq.identity))
      else
        flash[:notice] = "Do you trust this site with your identity?"
        session[:last_oidreq] = oidreq
        redirect_to :decide
      end
    else
      session[:last_oidreq] = oidreq
      redirect_to new_session_url
    end
  end

  def decide
    @oidreq = session[:last_oidreq]
  end

  def decision
    oidreq = session[:last_oidreq]
    session[:last_oidreq] = nil

    if params[:result] == 'yes'
      (session[:approvals] << oidreq.trust_root).uniq!
      render_response positive_response(oidreq, url_for_user)
    else
      redirect_to oidreq.cancel_url
    end
  end

  def user_page
  end

  protected

  def url_for_user
    if session[:username].blank?
      nil
    else
      user_url :username => session[:username]
    end
  end
end
