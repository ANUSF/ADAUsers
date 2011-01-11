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

    oidresp = nil

    if oidreq.kind_of?(CheckIDRequest)
      identity = oidreq.identity

      if oidreq.id_select
        if oidreq.immediate
          oidresp = oidreq.answer(false)
        elsif session[:username].nil?
          show_decision_page(oidreq)
          return
        else
          # Else, set the identity to the one the user is using.
          identity = url_for_user
        end
      end

      if oidresp
        nil
      elsif is_authorized(identity, oidreq.trust_root)
        oidresp = oidreq.answer(true, nil, identity)
        add_sreg(oidreq, oidresp)
        add_pape(oidreq, oidresp)
      elsif oidreq.immediate
        oidresp = oidreq.answer(false, index_url)
      else
        show_decision_page(oidreq)
        return
      end

    else
      oidresp = server.handle_request(oidreq)
    end

    render_response(oidresp)
  end

  def show_decision_page(oidreq,
                         message = "Do you trust this site with your identity?")
    @oidreq = session[:last_oidreq] = oidreq
    flash[:notice] = message unless message.blank?
    render 'decide', :layout => 'identities'
  end

  def user_page
    # Yadis content-negotiation: we want to return the xrds if asked for.
    accept = request.env['HTTP_ACCEPT']

    # This is not technically correct, and should eventually be updated
    # to do real Accept header parsing and logic.  Though I expect it will work
    # 99% of the time.
    if accept and accept.include?('application/xrds+xml')
      user_xrds
    else
      # content negotiation failed, so just render the user page
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
      show_decision_page oidreq,
        "You must enter a username to in order to send " +
        "an identifier to the Relying Party."
    else
      if oidreq.id_select
        session[:username] = params[:id_to_send]
        session[:approvals] = []
        identity = url_for_user
      else
        identity = oidreq.identity
      end

      (session[:approvals] ||= []) << oidreq.trust_root

      oidresp = oidreq.answer(true, nil, identity)
      add_sreg(oidreq, oidresp)
      add_pape(oidreq, oidresp)
      render_response(oidresp)
    end
  end

  def logout
    session[:username] = nil
    redirect_to params[:return_url]
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

  def approved(trust_root)
    (session[:approvals] || []).include? trust_root
  end

  def is_authorized(identity_url, trust_root)
    session[:username] and identity_url == url_for_user and approved trust_root
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
      # In a real application, this data would be user-specific,
      # and the user should be asked for permission to release it.
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
