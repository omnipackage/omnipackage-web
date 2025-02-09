source 'https://rubygems.org'

# update to AWS gems causes issues on CloudFlare, keep these locked
# https://github.com/aws/aws-sdk-ruby/issues/3174
# https://www.cloudflarestatus.com/incidents/t5nrjmpxc1cj
# gem 'aws-sdk-core', '3.214.1'
gem 'aws-sdk-s3' # , '1.176.1'

gem 'bcrypt'
gem 'bootsnap', require: false
gem 'importmap-rails'
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
