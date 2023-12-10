# frozen_string_literal: true

::ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'sidekiq/testing'

::Sidekiq::Testing.fake!
::Sidekiq.configure_client do |config|
  config.logger.level = ::Logger::WARN
end

module ActiveSupport
  class TestCase
    include ::FactoryBot::Syntax::Methods

    parallelize(workers: :number_of_processors)

    def sign_in_as(user)
      post(sign_in_url, params: { email: user.email, password: 'Secret1*3*5*' })
      user
    end

    def after_teardown
      super
      ::FileUtils.rm_rf(::ActiveStorage::Blob.service.root)
    end

    parallelize_setup do |i|
      ::ActiveStorage::Blob.service.root = "#{::ActiveStorage::Blob.service.root}-#{i}"
    end
  end
end
