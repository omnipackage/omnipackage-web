# frozen_string_literal: true

namespace :embedded_agents do # rubocop: disable Metrics/BlockLength
  desc 'Run embedded agents (if any)'
  task run: [:environment, :load_gem] do
    url_options = ::Rails.application.config.action_mailer.default_url_options
    host = url_options.fetch(:host, 'localhost')
    port = url_options.fetch(:port, 80)
    apihost = "http://#{host}:#{port}"

    ::Agent.where("name LIKE '%embedded%' AND user_id IS NULL").map do |a|
      ::Thread.new do
        config = ::OmnipackageAgent::Config.new(
          apihost:            apihost,
          apikey:             a.apikey,
          container_runtime:  ::APP_SETTINGS[:container_runtime],
          build_dir:          ::Pathname.new(::Dir.tmpdir).join("omnipackage-build-#{a.name}").to_s,
          lockfiles_dir:      ::Pathname.new(::Dir.tmpdir).join('omnipackage-lock').to_s,
        )
        log_formatter = ::OmnipackageAgent::Logging::Formatter.new(tags: [a.name])
        logger = ::OmnipackageAgent::Logging::Logger.new(formatter: log_formatter)
        ::OmnipackageAgent.run(config, logger: logger)
      end
    end.each(&:join)
  end

  desc 'Create new embedded agent'
  task create: :environment do
    max = ::Agent.where("name LIKE '%embedded%' AND user_id IS NULL").pluck(:name).map { |i| i.gsub('embedded_', '').to_i }.max || 0
    pp ::Agent.create!(name: "embedded_#{max + 1}", arch: ::Distro.arches.first)
  end

  desc 'Load agent gem'
  task load_gem: :environment do
    localpath = ::Rails.root.join('../omnipackage-agent-ruby/lib').expand_path.to_s
    instalpath = '/usr/lib/omnipackage-agent-ruby/lib'
    if ::File.exist?(localpath)
      $LOAD_PATH.unshift(localpath)
    elsif ::File.exist?(instalpath)
      $LOAD_PATH.unshift(instalpath)
    end

    begin
      require 'omnipackage_agent'
    rescue ::LoadError
      warn 'you have to install omnipackage agen'
      exit(1)
    end
  end
end
