Dealbook::Application.routes.draw do
  devise_for :users, path_names: { sign_in: "login", sign_out: "logout" },
                    controllers: { omniauth_callbacks: "omniauth_callbacks" }

  get "/users/unlink" => "authentications#unlink", as: "unlink"

  get "deal_graph" => "deal_graph#index"

  resources :users, :only => [:show, :index, :edit, :update]
  resources :deals do
    put :verify, :on => :member
    put :unverify, :on => :member
  end
  resources :companies
  resources :investors
  resources :dealings, :only => :index
  resources :markets, :except => :show
  resources :locations, :except => :show
  resources :searches, :only => [:show, :create]
  resources :home, :only => :index

  authenticated :user do
    root :to => 'home#index'
  end

  root :to => "home#index"
end
