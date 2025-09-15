module RepoManage
  class Runtime
    attr_reader :executable, :workdir, :setup_cli, :homedir, :limits, :lock

    # rubocop: disable Metrics/MethodLength
    def initialize(
      workdir:,
      image:,
      setup_cli:,
      executable:,
      limits: ::RepoManage::Runtime::Limits.new(enabled: ::APP_SETTINGS[:publish_container_limits_enable])
    )
      @executable = executable
      @workdir = workdir
      @setup_cli = setup_cli
      @homedir = ::Dir.mktmpdir
      @image_cache = ::RepoManage::Runtime::ImageCache.new(executable:, default_image: image, setup_cli:, enabled: ::APP_SETTINGS[:image_cache_enable])
      @limits = limits
      @lock = ::RepoManage::Runtime::Lock.new(key: image_cache.container_name, limits:)

      ::Rails.error.set_context(
        default_image:  image_cache.default_image,
        limits:         limits.inspect,
        container_name: image_cache.container_name
      )
    end
    # rubocop: enable Metrics/MethodLength

    def execute(commands)
      raise 'execute can only be used once' if frozen?

      begin
        ::ShellUtil.execute(build_container_cli(setup_cli + commands), timeout_sec: limits.execute_timeout).success!
      ensure
        ::FileUtils.remove_entry_secure(homedir)
        freeze
      end
    end

    private

    attr_reader :image_cache

    def mounts
      {
        workdir => '/workdir',
        homedir => '/root'
      }
    end

    def mount_cli
      mounts.map do |from, to|
        "--mount type=bind,source=#{from},target=#{to}"
      end.join(' ')
    end

    def envs
      {
        'GPG_TTY' => '' # export GPG_TTY=$(tty)
      }
    end

    def envs_cli
      envs.map do |k, v|
        "--env #{k}=#{v}"
      end.join(' ')
    end

    def fix_permissions(commands)
      if executable == 'docker'
        commands.unshift('umask 000')
        mounts.each do |_from, to|
          commands << "chown -R #{::Process.uid}:#{::Process.gid} #{to}"
        end
      end
    end

    def build_container_cli(commands) # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
      fix_permissions(commands)

=begin
      script = <<~SCRIPT
      #!/bin/bash
      set -x
      #{commands.join("\n")}
      SCRIPT
      ::File.open(::Pathname.new(homedir).join('script'), 'w') { |file| file.write(script) }
=end
      if image_cache.enabled
        <<~CLI
          #{lock.to_cli} '#{image_cache.rm_cli} ; #{executable} run --name #{image_cache.container_name} --entrypoint /bin/bash --workdir #{mounts[workdir]} #{mount_cli} #{envs_cli} #{limits.to_cli} #{image_cache.image} -c "#{commands.join(' && ')}" && #{image_cache.commit_cli}'
        CLI
      else
        <<~CLI
          #{executable} run --rm --entrypoint /bin/bash --workdir #{mounts[workdir]} #{mount_cli} #{envs_cli} #{limits.to_cli} #{image_cache.image} -c "#{commands.join(' && ')}"
        CLI
      end
    end
  end
end
