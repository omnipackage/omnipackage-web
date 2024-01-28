# frozen_string_literal: true

source 'https://rubygems.org'

gem 'aws-sdk-s3'
gem 'bcrypt', '~> 3.1.7'
gem 'importmap-rails'
gem 'pg'
gem 'puma'
gem 'rails'
gem 'redis'
gem 'sidekiq'
gem 'sidekiq-scheduler'
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

  if ::Gem::Version.new(::RUBY_VERSION) >= ::Gem::Version.new('3.3')
    gem 'readline-ext' # https://github.com/ruby/reline/issues/618
  end
end

group :development do
  # gem 'authentication-zero'
  gem 'pry-rails'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end
