redis_config = { url: ::ENV.fetch('REDIS_URL') { 'redis://localhost:6379/11' } }

::Sidekiq.configure_server do |config|
  config.redis = redis_config

  config.error_handlers << proc do |e, context, _sidekiq_config = nil|
    ::Rails.error.report(e, context: context, severity: :error)
  end
end

::Sidekiq.configure_client do |config|
  config.redis = redis_config
end
