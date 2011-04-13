ADAUsers::Application.routes.draw do
  resource :session
  resources :decisions

  match 'datasets/restricted/:series' => 'access_levels#datasets_restricted', :constraints => {:series => /.+/}

  resources :users, :constraints => {:id => /.+/} do
    resources :undertakings
    match 'reset_password' => 'users#reset_password', :on => :collection
    get :change_password, :on => :member
  end

  namespace "admin" do
    resources :users, :except => :show, :constraints => {:id => /.+/} do
      get :search, :on => :collection
      resources :permissions_a, :controller => "user_permissions_a"
      resources :permissions_b, :controller => "user_permissions_b"
    end
    resources :undertakings do
      match 'mark_complete/:processed', :to => 'undertakings#mark_complete', :as => 'mark_complete'
    end
  end

  match 'login',  :to => 'sessions#new'
  match 'logout', :to => 'sessions#destroy'

  match 'server', :to => 'identities#index', :as => 'server'
  get 'user/*username', :to => 'users#show', :format => false


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
