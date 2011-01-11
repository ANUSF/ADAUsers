OpenidServer::Application.routes.draw do
  match 'index',               :to => 'identities#index'
  match 'xrds',                :to => 'identities#idp_xrds'
  match 'decision',            :to => 'identities#decision'
  match 'user/xrds/*username', :to => 'identities#user_xrds', :as => 'user_xrds',
                               :format => false
  match 'user/*username',      :to => 'identities#user_page', :as => 'user',
                               :format => false
  match 'logout',              :to => 'identities#logout'

  root                         :to => 'identities#index'
end
