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

    oidresp =
      if oidreq.kind_of?(CheckIDRequest)
        if oidreq.immediate
          oidreq.answer(false, index_url)
        else
          identity = oidreq.id_select ? url_for_user : oidreq.identity
          is_authorized(identity, oidreq.trust_root) and
            positive_response(oidreq, identity)
        end
      else
        server.handle_request(oidreq)
      end

    if oidresp
      render_response(oidresp)
    else
      flash[:notice] = "Do you trust this site with your identity?"
      show_decision_page(oidreq)
    end
  end

  def show_decision_page(oidreq)
    @oidreq = session[:last_oidreq] = oidreq
    render 'decide'
  end

  def user_page
    if (request.env['HTTP_ACCEPT'] || []).include?('application/xrds+xml')
      user_xrds
    else
      response.headers['X-XRDS-Location'] =
        user_xrds_url :username => params[:username]
      render :text => <<EOF
<html><head>
<meta http-equiv="X-XRDS-Location" content="#{xrds_url}" />
<link rel="openid.server" href="#{index_url}" />
</head><body><p>OpenID identity page for #{params[:username]}</p>
</body></html>
EOF
    end
  end

  def user_xrds
    render_xrds [ OpenID::OPENID_2_0_TYPE,
                  OpenID::OPENID_1_0_TYPE,
                  OpenID::SREG_URI        ]
  end

  def idp_xrds
    render_xrds [ OpenID::OPENID_IDP_2_0_TYPE ]
  end

  def decision
    oidreq = session[:last_oidreq]
    session[:last_oidreq] = nil

    if params[:yes].nil?
      redirect_to oidreq.cancel_url
    elsif oidreq.id_select and params[:id_to_send].blank?
      flash[:notice] = 
        "You must enter a username in order to send " +
        "an identifier to the Relying Party."
      show_decision_page(oidreq)
    else
      if oidreq.id_select
        session[:username] = params[:id_to_send]
        session[:approvals] = []
        identity = url_for_user
      else
        identity = oidreq.identity
      end

      (session[:approvals] ||= []) << oidreq.trust_root
      render_response positive_response(oidreq, identity)
    end
  end

  def logout
    session[:username] = nil
    if params[:return_url]
      redirect_to params[:return_url]
    else
      render :text => "Successfully logged out."
    end
  end

  protected

  def url_for_user
    user_url :username => session[:username]
  end

  def server
    if @server.nil?
      dir = File.join(Rails.root, 'db', 'openid-store')
      store = OpenID::Store::Filesystem.new(dir)
      @server = Server.new(store, index_url)
    end
    @server
  end

  def is_authorized(identity_url, trust_root)
    session[:username] and identity_url == url_for_user and
      (session[:approvals] || []).include? trust_root
  end

  def render_xrds(types)
    response.headers['content-type'] = 'application/xrds+xml'
    render :text => <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns="xri://$xrd*($v*2.0)">
  <XRD>
    <Service priority="0">
      #{types.map { |uri| "<Type>#{uri}</Type>" }.join "\n      "}
      <URI>#{index_url}</URI>
    </Service>
  </XRD>
</xrds:XRDS>
EOS
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
