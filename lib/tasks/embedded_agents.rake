namespace :embedded_agents do # rubocop: disable Metrics/BlockLength
  desc 'Run embedded agents (if any)'
  task run: [:environment, :load_gem] do # rubocop: disable Metrics/BlockLength
    apihost = if ::ENV['EMBEDDED_AGENTS_APIHOST']
                ::ENV['EMBEDDED_AGENTS_APIHOST']
              else
                url_options = ::Rails.application.config.action_mailer.default_url_options
                host = url_options.fetch(:host, 'localhost')
                port = url_options.fetch(:port, 80)
                "http://#{host}:#{port}"
              end

    external_build_dir = '/home/oleg/Desktop/omnipackage-build/'

    ::Agent.where("name LIKE '%embedded%' AND user_id IS NULL").map do |a|
      build_dir = if ::Rails.env.development? && ::File.exist?(external_build_dir)
                    ::Pathname.new(external_build_dir).join(a.name)
                  else
                    ::Pathname.new(::Dir.tmpdir).join("omnipackage-build-#{a.name}")
                  end.to_s

      ::Thread.new do # rubocop: disable ThreadSafety/NewThread
        config = ::OmnipackageAgent::Config.get(overrides: {
          apihost:            apihost,
          apikey:             a.apikey,
          container_runtime:  ::APP_SETTINGS[:container_runtime],
          build_dir:          build_dir,
          container_limits_disable: ::ENV['EMBEDDED_AGENTS_LIMITS_DISABLE'].present?
        })
        log_formatter = ::OmnipackageAgent::Logging::Formatter.new(tags: [a.name])
        logger = ::OmnipackageAgent::Logging::Logger.new(formatter: log_formatter)
        ::OmnipackageAgent.run(config, logger: logger)
      end
    end.each(&:join)
  end

  desc 'Create new embedded agent'
  task create: :environment do
    max = ::Agent.where("name LIKE '%embedded%' AND user_id IS NULL").pluck(:name).map { |i| i.gsub('embedded_', '').to_i }.max || 0
    puts "created: #{::Agent.create!(name: "embedded_#{max + 1}", arch: ::Distro.arches.first).name}"
  end

  desc 'Deleta embedded agent'
  task delete: :environment do
    deleted = ::Agent.where("name LIKE '%embedded%' AND user_id IS NULL").order(:name).last
    if deleted
      deleted.destroy
      puts "deleted: #{deleted.name}"
    end
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
      warn 'you have to install omnipackage agent'
      exit(1)
    end
  end
end
