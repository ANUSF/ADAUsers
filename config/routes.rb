OpenidServer::Application.routes.draw do
  resources :sessions

  match 'login',  :to => 'sessions#new'
  match 'logout', :to => 'sessions#destroy'

  %w{index decide decision}.each do |action|
    match action, :to => "identities##{action}"
  end

  match 'user/*username', :to => 'users#show', :as => 'user', :format => false
end
