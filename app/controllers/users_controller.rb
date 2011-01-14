class UsersController < ApplicationController
  def show
    respond_to do |format|
      format.html do
        response.headers['X-XRDS-Location'] = xrds_user_url
      end
      format.xrds do
        render :text => %Q!<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns="xri://$xrd*($v*2.0)">
  <XRD>
    <Service priority="0">
      <Type>#{OpenID::OPENID_2_0_TYPE}</Type>
      <Type>#{OpenID::OPENID_1_0_TYPE}</Type>
      <Type>#{OpenID::SREG_URI}</Type>
      <URI priority="0">#{server_url}</URI>
    </Service>
  </XRD>
</xrds:XRDS>
!
      end
    end
  end
end
