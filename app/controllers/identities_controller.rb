class IdentitiesController < ApplicationController
  def root
    flash[:notice] = "Hello, Passenger!"

    respond_to do |format|
      format.html do
        response.headers['X-XRDS-Location'] = xrds_idp_url
      end
      format.xrds do
        render :text => render_xrds(OpenID::OPENID_IDP_2_0_TYPE)
      end
    end
  end

  def index
    p = params.reject { |key, val| %w{controller action}.include? key }
    oidreq =
      begin
        oidreq = server.decode_request(p)
      rescue OpenID::Server::ProtocolError => e
        render :text => "Invalid OpenID request: #{e.to_s}", :status => 500
        return
      end

    if oidreq.nil?
      render :text => "This is an OpenID endpoint.\n"
    elsif not oidreq.kind_of?(OpenID::Server::CheckIDRequest)
      render_response(server.handle_request(oidreq))
    elsif oidreq.immediate
      render_response(oidreq.answer(false, root_url))
    elsif is_logged_in_as(oidreq.identity) and not oidreq.id_select
      if (session[:approvals] || []).include? oidreq.trust_root
        render_response(positive_response(oidreq, session[:username]))
      else
        session[:last_oidreq] = oidreq
        redirect_to new_decision_url
      end
    else
      session[:last_oidreq] = oidreq
      redirect_to new_session_url
    end
  end
end
