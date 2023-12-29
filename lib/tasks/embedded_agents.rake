# frozen_string_literal: true

require 'omnipackage_agent'

namespace :embedded_agents do
  desc 'Run embedded egent (if any)'
  task run: :environment do
    agents = ::Agent.where("name LIKE '%embedded%'")

    a = agents.first
    return unless a

    url_options = ::Rails.application.config.action_mailer.default_url_options
    host = url_options.fetch(:host, 'localhost')
    port = url_options.fetch(:port, 80)

    ::OmnipackageAgent.config = ::OmnipackageAgent::Config.new(
      apihost: "http://#{host}:#{port}",
      apikey: a.apikey,
      container_runtime: ::APP_SETTINGS[:container_runtime],
      build_dir: ::Pathname.new(::Dir.tmpdir).join("omnipackage-agent-#{a.name}").to_s
    )
    ::OmnipackageAgent.run
  end
end
