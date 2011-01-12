OpenidServer::Application.routes.draw do
  %w{index decide decision logout}.each do |action|
    match action, :to => "identities##{action}"
  end
  match 'xrds',                :to => 'identities#idp_xrds'
  match 'user/xrds/*username', :to => 'identities#user_xrds', :as => 'user_xrds',
                               :format => false
  match 'user/*username',      :to => 'identities#user_page', :as => 'user',
                               :format => false
end
