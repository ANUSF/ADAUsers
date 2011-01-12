require "openid"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'


class ApplicationController < ActionController::Base
  #protect_from_forgery
  include OpenID::Server

  protected

  def is_logged_in_as(identity)
    session[:username] and user_url(:username => session[:username]) == identity
  end

  def username_for(identity)
    name = identity.sub /.*\/user\/(.*)/, '\\1'
    name if user_url(:username => name) == identity
  end

  def server
    unless defined? @server
      dir = File.join(Rails.root, 'db', 'openid-store')
      store = OpenID::Store::Filesystem.new(dir)
      @server = Server.new(store, index_url)
    end
    @server
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
