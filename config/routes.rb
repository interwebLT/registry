Rails.application.routes.draw do
  get '/site/sha', to: 'site#sha'

  root to: 'welcome#index'

  resources :welcome,         only: [:index]
  resources :authorizations,  only: [:create, :show]
  resources :orders,          only: [:index, :create, :show]
  resources :credits,         only: [:index, :create, :show]
  resources :activities,      only: [:index]
  resources :migrations,      only: [:create]
  resources :contacts,        only: [:index, :create, :show, :update]

  resources :user, only: [:index] do
    collection do
      get :partner
    end
  end

  resources :domains, only: [:index, :show, :update], id: /.*/ do
    resources :hosts, controller: :domain_hosts, only: [:create, :show, :destroy]
  end

  get 'availability', to: 'availabilities#index'

  resources :partners, only: [:index, :show] do
    resources :users, only: [:create]
  end

  resources :hosts, only: [:index, :create, :show], id: /.*/ do
    resources :addresses, controller: :host_addresses, only: [:create, :show, :destroy]
  end

  match '*unmatched', to: 'application#handle_routing_error', via: :all
end
