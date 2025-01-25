source 'https://rubygems.org'

# update to AWS gems causes issuis on CloudFlare, keep these locked
gem 'aws-eventstream', '1.3.0'
gem 'aws-partitions', '1.1029.0'
gem 'aws-sdk-core', '3.214.1'
gem 'aws-sdk-kms', '1.96.0'
gem 'aws-sdk-s3', '1.176.1'
gem 'aws-sigv4', '1.10.1'

gem 'bcrypt'
gem 'bootsnap', require: false
gem 'importmap-rails'
gem 'ostruct' # warning: /home/debian/.rbenv/versions/3.4.1/lib/ruby/3.4.0/ostruct.rb was loaded from the standard library, but will no longer be part of the default gems starting from Ruby 3.5.0
gem 'pg'
gem 'propshaft'
gem 'pry-rails'
gem 'puma'
gem 'rails'
gem 'redis'
gem 'rollbar'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'brakeman', require: false
  gem 'bundle-audit', require: false
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-thread_safety', require: false
  gem 'super_awesome_print'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end

group :development do
  gem 'authentication-zero'
end
