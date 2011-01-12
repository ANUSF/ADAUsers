OpenidServer::Application.routes.draw do
  %w{index decide decision logout}.each do |action|
    match action, :to => "identities##{action}"
  end
  match 'user/*username', :to => 'identities#user_page', :as => 'user',
                          :format => false
end
