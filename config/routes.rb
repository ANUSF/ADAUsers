OpenidServer::Application.routes.draw do
  resources :sessions
  resources :decisions

  match 'login',  :to => 'sessions#new'
  match 'logout', :to => 'sessions#destroy'

  match 'server', :to => 'identities#index', :as => 'server'

  match 'user/*username', :to => 'users#show', :as => 'user', :format => false


  # A bit of trickery to serve XRDS from bare URLs

  match 'xrds/user/*username', :to => lambda { |env|
    env['HTTP_ACCEPT'] = 'application/xrds+xml'
    UsersController.action(:show).call(env)
  }

  match 'xrds/idp', :to => lambda { |env|
    env['HTTP_ACCEPT'] = 'application/xrds+xml'
    IdentitiesController.action(:root).call(env)
  }

  root :to => 'identities#root'
end
