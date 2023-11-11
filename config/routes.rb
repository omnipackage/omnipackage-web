# frozen_string_literal: true

require 'sidekiq/web'

::Rails.application.routes.draw do
  root 'home#index'

  mount ::Sidekiq::Web => '/sidekiq', constraints: ::Session::RouteConstraint.new(:root?)

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

  namespace :agent_api do
    post '/', to: 'api#call'
    get '/sources_tarball/:task_id', to: 'api#sources_tarball', as: 'download_sources_tarball'
    post '/artefacts/:task_id', to: 'api#upload_artefact', as: 'upload_artefact'
  end

  resources :projects do
    post :generate_ssh_keys
    post :fetch_sources
    get :download_tarball
  end

  resources :agents
  resources :tasks, only: %i[index show destroy create]
  resources :repositories, except: %i[edit update]
end
