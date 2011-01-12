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

    oidresp = 
      if oidreq.kind_of?(CheckIDRequest)
        if oidreq.immediate
          oidreq.answer(false, index_url)
        else
          identity = oidreq.id_select ? url_for_user : oidreq.identity
          authorized = (identity == url_for_user) and
            (session[:approvals] || []).include? oidreq.trust_root
          positive_response(oidreq, identity) if authorized
        end
      else
        server.handle_request(oidreq)
      end

    if oidresp
      render_response(oidresp)
    elsif is_logged_in_as(oidreq.identity)
      flash[:notice] = "Do you trust this site with your identity?"
      session[:last_oidreq] = oidreq
      redirect_to :decide
    else
      session[:last_oidreq] = oidreq
      redirect_to new_session_url
    end
  end

  def decide
    @oidreq = session[:last_oidreq]
    render 'decide'
  end

  def decision
    oidreq = session[:last_oidreq]

    if params[:result] != 'yes'
      session[:last_oidreq] = nil
      redirect_to oidreq.cancel_url
    elsif oidreq.id_select and params[:id_to_send].blank?
      flash[:notice] = 
        "You must enter a username in order to send " +
        "an identifier to the Relying Party."
      redirect_to :decide
    else
      username =
        oidreq.id_select ? params[:id_to_send] : username_for(oidreq.identity)
      session[:approvals] = [] if username != session[:username]
      session[:username] = username

      session[:approvals] ||= []
      unless session[:approvals].include? oidreq.trust_root
        session[:approvals] << oidreq.trust_root
      end
      session[:last_oidreq] = nil
      render_response positive_response(oidreq, url_for_user)
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
