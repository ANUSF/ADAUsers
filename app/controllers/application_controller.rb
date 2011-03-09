require "openid"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'


class ApplicationController < ActionController::Base
  protect_from_forgery :except => :index

  helper_method :current_identity, :username_for, :current_user

  protected

  def current_identity
    url_for :username => session[:username]
  end

  def username_for(identity)
    name = identity.sub /.*\/user\/(.*)/, '\\1'
    name if user_url(:username => name) == identity
  end

  def is_logged_in_as(identity)
    session[:username] and user_url(:username => session[:username]) == identity
  end

  def current_user
    return @current_user if defined? @current_user
    @current_user = session[:username] ? User.find_by_user(session[:username]) : nil
  end

  def require_user
    unless current_user
      flash[:notice] = "You must be logged in to access this page."
      redirect_to login_url
      return false
    end
  end

  def require_no_user
    if current_user
      flash[:notice] = "You must be logged out to access this page."
      redirect_to root_url
      return false
    end
  end

  def require_admin
    unless current_user and current_user.admin?
      flash[:notice] = "You must be an administrator to access this page."
      redirect_to root_url
      return false
    end
  end

  def server
    unless defined? @server
      dir = File.join(Rails.root, 'db', 'openid-store')
      store = OpenID::Store::Filesystem.new(dir)
      @server = OpenID::Server::Server.new(store, root_url)
    end
    @server
  end

  def add_sreg(oidreq, oidresp, username)
    sregreq = OpenID::SReg::Request.from_openid_request(oidreq)

    unless sregreq.nil?
      user = User.find_by_user username

      sreg_data = {
        'nickname' => user.user,
        'fullname' => [user.title, user.fname, user.sname].compact.join(' '),
        'email' => user.email
      }

      sregresp = OpenID::SReg::Response.extract_response(sregreq, sreg_data)
      oidresp.add_extension(sregresp)
    end
  end

  def add_pape(oidreq, oidresp, username)
    papereq = OpenID::PAPE::Request.from_openid_request(oidreq).nil?

    unless papereq.nil?
      paperesp = OpenID::PAPE::Response.new
      paperesp.nist_auth_level = 0 # bump to 2 when we have HTTPS
      oidresp.add_extension(paperesp)
    end
  end

  def positive_response(oidreq, username)
    oidresp = oidreq.answer(true, server_url, user_url(username))
    add_sreg(oidreq, oidresp, username)
    add_pape(oidreq, oidresp, username)
    oidresp
  end

  def render_response(oidresp)
    server.signatory.sign(oidresp) if oidresp.needs_signing
    web_response = server.encode_response(oidresp)

    if web_response.code == OpenID::Server::HTTP_REDIRECT
      redirect_to web_response.headers['location']
    else
      render :text => web_response.body, :status => web_response.code
    end
  end

  def render_xrds(*types)
    type_str = types.map { |uri| "<Type>#{uri}</Type>" }.join "\n      "

    %Q!<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns="xri://$xrd*($v*2.0)">
  <XRD>
    <Service priority="0">
      #{type_str}
      <URI priority="0">#{server_url}</URI>
    </Service>
  </XRD>
</xrds:XRDS>
!
  end
end
