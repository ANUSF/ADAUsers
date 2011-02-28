OpenidServer::Application.routes.draw do
  resources :sessions
  resources :decisions

  match 'users/search', :to => 'users#search', :as => 'user_search'
  resources :users, :constraints => {:id => /.+/} do
    resources :permissions_a, :controller => "user_permissions_a"
  end

  match 'login',  :to => 'sessions#new'
  match 'logout', :to => 'sessions#destroy'

  match 'server', :to => 'identities#index', :as => 'server'
  get 'user/*username', :to => 'users#show', :format => false  #:as => 'user'


  # A bit of trickery to serve XRDS from bare URLs

  match 'xrds/user/*username', :as => 'xrds_user', :to => lambda { |env|
    env['HTTP_ACCEPT'] = 'application/xrds+xml'
    UsersController.action(:show).call(env)
  }

  match 'xrds/idp', :to => lambda { |env|
    env['HTTP_ACCEPT'] = 'application/xrds+xml'
    IdentitiesController.action(:root).call(env)
  }

  root :to => 'identities#root'
end
