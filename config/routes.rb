# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

::Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  root 'projects#index'

  mount ::Sidekiq::Web => '/sidekiq', constraints: ::Session::RouteConstraint.new(:root?)

  %i[about docs home transparency privacy].each do |link|
    direct "links_#{link}" do |options|
      ::APP_SETTINGS.dig(:links, link) || options[:fallback] || '#'
    end
  end

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
    resources :ssh_keys, only: %i[create] do
      post :copy, on: :collection
    end
    resources :sources, only: %i[index create]
    resources :webhooks, only: %i[index create show new update destroy]
    resource :custom_repository_storage, only: %i[create new update edit destroy]
  end

  resources :agents
  resources :tasks, only: %i[index show create] do
    get 'log', on: :member
    post 'cancel', on: :member
  end
  resources :repositories, only: %i[index show destroy] do
    concerns :gpg_keys
  end

  get ':user_slug/:project_slug/install', to: 'installs#index', as: 'package_install'

  post 'inbound_webhooks/:key', to: 'inbound_webhooks#trigger', as: 'trigger_webhook'

  ::PagesController::ALL.each do |page|
    get page, to: "pages##{page}", as: "pages_#{page}"
  end
end
