# frozen_string_literal: true

require 'omnipackage_agent'

namespace :embedded_agents do
  desc 'Run embedded egent (if any)'
  task run: :environment do
    url_options = ::Rails.application.config.action_mailer.default_url_options
    host = url_options.fetch(:host, 'localhost')
    port = url_options.fetch(:port, 80)
    apihost = "http://#{host}:#{port}"

    ::Agent.where("name LIKE '%embedded%'").map do |a|
      ::Thread.new do
        config = ::OmnipackageAgent::Config.new(
          apihost:            apihost,
          apikey:             a.apikey,
          container_runtime:  ::APP_SETTINGS[:container_runtime],
          build_dir:          ::Pathname.new(::Dir.tmpdir).join("omnipackage-agent-#{a.name}").to_s
        )
        log_formatter = ::OmnipackageAgent::Logging::Formatter.new(tags: [a.name])
        logger = ::OmnipackageAgent::Logging::Logger.new(formatter: log_formatter)
        ::OmnipackageAgent.api(config, logger: logger)
      end
    end.each(&:join)
  end
end
