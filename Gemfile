# frozen_string_literal: true

source 'https://rubygems.org'

gem 'aws-sdk-s3'
gem 'bcrypt', '~> 3.1.7'
gem 'importmap-rails'
gem 'pg'
gem 'puma'
gem 'rails', '~> 7.1.0.rc1'
gem 'redis'
gem 'sidekiq'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'brakeman', require: false
  gem 'bundle-audit', require: false
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'super_awesome_print'
end

group :development do
  # gem 'authentication-zero'
  gem 'foreman', require: false
  gem 'pry-rails'
end

group :test do
  gem 'capybara'
  gem 'rackup'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
