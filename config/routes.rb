OpenidServer::Application.routes.draw do
  match 'server/xrds',         :to => 'identities#idp_xrds'
  match 'user/*username',      :to => 'identities#user_page', :format => false
  match 'user/*username/xrds', :to => 'identities#user_xrds', :format => false
  match 'server/:action',      :to => 'identities'
end
