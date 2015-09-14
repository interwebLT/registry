Rails.application.routes.draw do
  get '/site/sha', to: 'site#sha'

  root to: 'welcome#index'

  resources :welcome, only: [:index]

  resources :authorizations, only: [:create, :show]

  resources :user, only: [:index] do
    collection do
      get :partner
    end
  end

  resources :domains, only: [:index, :show, :update], id: /.*/ do
    resources :hosts, controller: :domain_hosts, only: [:create, :show, :destroy]
  end

  resources :partners, only: [:index, :show]

  resources :orders, only: [:index, :create, :show]

  resources :credits, only: [:index, :create]

  resources :contacts, only: [:index, :create, :show, :update]

  resources :hosts, only: [:index, :create, :show], id: /.*/ do
    resources :addresses, controller: :host_addresses, only: [:create, :show, :destroy]
  end

  resources :activities, only: [:index]

  resources :migrations, only: [:create]

  match '*unmatched', to: 'application#handle_routing_error', via: :all
end
