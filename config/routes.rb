Rails.application.routes.draw do
  get '/site/sha', to: 'site#sha'

  root to: 'welcome#index'

  resources :welcome,         only: [:index]
  resources :authorizations,  only: [:create, :show]
  resources :orders,          only: [:index, :create, :show]
  resources :credits,         only: [:index, :create, :show]
  resources :activities,      only: [:index]
  resources :migrations,      only: [:create]
  resources :contacts,        only: [:index, :create, :show, :update, :destroy], id: /.*/
  resources :partners,        only: [:index, :show]
  resources :nameservers,     only: [:index]

  namespace :powerdns do
    resources :records
    resources :domains
  end

  get '/whois/:id',               to: 'whois#show',           as: :whois, id: /.*/
  get '/availability',            to: 'availabilities#index'
  get '/check_ns_authorization',  to: 'domains#check_nameserver_authorization'

  resources :user, only: [:index] do
    collection do
      get :partner
    end
  end

  resources :domains, only: [:index, :show, :update, :destroy], id: /.*/ do
    resources :hosts, controller: :domain_hosts, only: [:create, :show, :update, :destroy]
  end

  resources :hosts, only: [:index, :create, :show], id: /.*/ do
    resources :addresses, controller: :host_addresses, only: [:create, :show, :destroy]
  end

  match '*unmatched', to: 'application#handle_routing_error', via: :all
end
