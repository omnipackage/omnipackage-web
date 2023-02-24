# frozen_string_literal: true

require 'sidekiq/web'

::Rails.application.routes.draw do
  root 'home#index'

  mount ::Sidekiq::Web => '/sidekiq', :constraints => ::Session::RouteConstraint.new

  get  'sign_in', to: 'sessions#new'
  post 'sign_in', to: 'sessions#create'
  get  'sign_up', to: 'registrations#new'
  post 'sign_up', to: 'registrations#create'
  resources :sessions, only: %i[index show destroy]
  resource  :password, only: %i[edit update]
  namespace :identity do
    resource :email,              only: %i[edit update]
    resource :email_verification, only: %i[edit create]
    resource :password_reset,     only: %i[new edit create update]
    resource :account,            only: %i[show]
  end

  resources :projects do
    post :generate_ssh_keys
    post :fetch_sources
  end
end
