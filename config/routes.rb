OpenidServer::Application.routes.draw do
  match 'server/xrds',         :to => 'identities#idp_xrds'
  match 'server/index',        :to => 'identities#index'
  match 'server/decision',     :to => 'identities#decision'
  match 'user/*username',      :to => 'identities#user_page', :format => false
  match 'user/*username/xrds', :to => 'identities#user_xrds', :format => false
end
