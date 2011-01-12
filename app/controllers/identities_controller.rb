require "openid"
require "openid/consumer/discovery"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'


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

    if oidresp = automatic_response_to(oidreq)
      render_response(oidresp)
    else
      flash[:notice] = "Do you trust this site with your identity?"
      session[:last_oidreq] = oidreq
      redirect_to :decide
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
        if oidreq.id_select
          params[:id_to_send]
        else
          oidreq.identity.sub /.*\/user\/(.*)/, '\\1'
        end
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

  def logout
    session[:username] = nil
    session[:approvals] = []
    if params[:return_url]
      redirect_to params[:return_url]
    else
      render :text => "Successfully logged out."
    end
  end

  protected

  def url_for_user
    if session[:username].blank?
      nil
    else
      user_url :username => session[:username]
    end
  end

  def server
    unless defined? @server
      dir = File.join(Rails.root, 'db', 'openid-store')
      store = OpenID::Store::Filesystem.new(dir)
      @server = Server.new(store, index_url)
    end
    @server
  end

  def automatic_response_to(oidreq)
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
  end

  def add_sreg(oidreq, oidresp)
    sregreq = OpenID::SReg::Request.from_openid_request(oidreq)

    unless sregreq.nil?
      # TODO return the real data
      sreg_data = {
        'nickname' => session[:username],
        'fullname' => 'Mayor McCheese',
        'email' => 'mayor@example.com'
      }

      sregresp = OpenID::SReg::Response.extract_response(sregreq, sreg_data)
      oidresp.add_extension(sregresp)
    end
  end

  def add_pape(oidreq, oidresp)
    papereq = OpenID::PAPE::Request.from_openid_request(oidreq).nil?

    unless papereq.nil?
      paperesp = OpenID::PAPE::Response.new
      paperesp.nist_auth_level = 0 # we don't even do auth at all!
      oidresp.add_extension(paperesp)
    end
  end

  def positive_response(oidreq, identity)
    oidresp = oidreq.answer(true, nil, identity)
    add_sreg(oidreq, oidresp)
    add_pape(oidreq, oidresp)
    oidresp
  end

  def render_response(oidresp)
    server.signatory.sign(oidresp) if oidresp.needs_signing
    web_response = server.encode_response(oidresp)

    if web_response.code == HTTP_REDIRECT
      redirect_to web_response.headers['location']
    else
      render :text => web_response.body, :status => web_response.code
    end
  end
end
