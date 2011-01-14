OpenidServer::Application.routes.draw do
  resources :sessions
  resources :decisions

  match 'login',  :to => 'sessions#new'
  match 'logout', :to => 'sessions#destroy'

  match 'server', :to => 'identities#index', :as => 'server'

  match 'user/*username', :to => 'users#show', :as => 'user', :format => false


  # Handle some XRDS requests via Rack so that the content type is set correctly

  def xrds_text(env, mode)
    types = if mode == 'idp'
              [ OpenID::OPENID_IDP_2_0_TYPE ]
            else
              [ OpenID::OPENID_2_0_TYPE,
                OpenID::OPENID_1_0_TYPE,
                OpenID::SREG_URI         ]
            end
    type_str = types.map { |uri| "<Type>#{uri}</Type>" }.join "\n      "
    server = env['REQUEST_URI'].sub(/#{env['PATH_INFO']}$/, '/server')

    %Q!<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns="xri://$xrd*($v*2.0)">
  <XRD>
    <Service priority="0">
      #{type_str}
      <URI>#{server}</URI>
    </Service>
  </XRD>
</xrds:XRDS>
!
  end

  match 'xrds/user', :to => lambda { |env|
    [200, { "Content-Type" => "application/xrds+xml" }, [xrds_text env, 'user']]
  }

  match 'xrds/idp', :to => lambda { |env|
    [ 200, { "Content-Type" => "application/xrds+xml" }, [xrds_text env, 'idp']]
  }

  root :to => 'identities#root'
end
