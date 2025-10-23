require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
::Bundler.require(*::Rails.groups)

module OmnipackageWeb
  class Application < ::Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #

    config.active_job.queue_adapter = :sidekiq
    config.time_zone = 'UTC'

    config.active_record.encryption.primary_key = ::ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY']
    config.active_record.encryption.deterministic_key = ::ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY']
    config.active_record.encryption.key_derivation_salt = ::ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT']

  end
end
