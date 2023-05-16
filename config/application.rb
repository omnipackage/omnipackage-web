# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
::Bundler.require(*Rails.groups)

module OmnipackageWeb
  class Application < ::Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #

    %w(lib).each do |i|
      config.autoload_paths << config.root.join(i)
      config.eager_load_paths << config.root.join(i)
    end

    config.active_job.queue_adapter = :sidekiq
    config.time_zone = 'UTC'
  end
end
