# frozen_string_literal: true

require 'sidekiq/web'

::Rails.application.routes.draw do
  root 'home#index'

  mount ::Sidekiq::Web => '/sidekiq', constraints: ::Session::RouteConstraint.new(:root?)

  concern :gpg_keys do
    get 'gpg_key', to: 'gpg_keys#index', as: :index_gpg_key
    post 'gpg_key/generate', to: 'gpg_keys#generate', as: :generate_gpg_key
    post 'gpg_key/upload', to: 'gpg_keys#upload', as: :upload_gpg_key
    delete 'gpg_key/destroy', to: 'gpg_keys#destroy', as: :destroy_gpg_key
  end

  get  'sign_in', to: 'sessions#new'
  post 'sign_in', to: 'sessions#create'
  get  'sign_up', to: 'registrations#new'
  post 'sign_up', to: 'registrations#create'
  resources :sessions, only: %i[index show destroy] do
    delete 'destroy_all_but_current', on: :collection
  end
  resource  :password, only: %i[edit update]
  namespace :identity do
    resource :email,              only: %i[edit update]
    resource :email_verification, only: %i[edit create]
    resource :password_reset,     only: %i[new edit create update]
    resource :account,            only: %i[show update]
  end

  scope '/account' do
    concerns :gpg_keys
  end

  namespace :agent_api do
    post '/', to: 'api#call'
    # get '/sources_tarball/:task_id', to: 'api#sources_tarball', as: 'download_sources_tarball'
    post '/artefacts/:task_id', to: 'api#upload_artefact', as: 'upload_artefact'
  end

  resources :projects do
    resources :ssh_keys, only: %i[create]
    resources :sources, only: %i[index create]
    resources :webhooks, only: %i[index create show new update destroy]
  end

  resources :agents
  resources :tasks, only: %i[index show create] do
    get 'log', on: :member
    post 'cancel', on: :member
  end
  resources :repositories, only: %i[show] do
    concerns :gpg_keys
  end
  resources :distros, only: %i[index]

  get ':project_id/install', to: 'installs#index', as: 'package_install'

  post 'inbound_webhooks/:key', to: 'inbound_webhooks#trigger', as: 'trigger_webhook'
end
