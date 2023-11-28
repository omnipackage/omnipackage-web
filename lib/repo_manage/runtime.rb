# frozen_string_literal: true

module RepoManage
  class Runtime
    attr_reader :executable, :workdir, :image, :setup_cli, :homedir, :limits

    def initialize(workdir:, image:, setup_cli:, executable:, limits: ::RepoManage::Runtime::Limits.new)
      @executable = executable
      @workdir = workdir
      @image = image
      @setup_cli = setup_cli
      @homedir = ::Dir.mktmpdir
      @image_cache = ::RepoManage::Runtime::ImageCache.new(executable: executable)
      @limits = limits
      @mutex = ::DistributedMutex.new
    end

    def execute(commands) # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
      ::Rails.error.set_context(image: image, limits: limits.inspect, container_name: container_name)

      raise 'execute can only be used once' if frozen?

      mutex.with_lock(container_name, timeout_sec: limits.execute_timeout + 30, wait_sec: limits.execute_timeout) do
        if image_cache.exists?(container_name)
          image_cache.rm(container_name)
        end

        begin
          ::ShellUtil.execute(build_container_cli(setup_cli + commands), timeout_sec: limits.execute_timeout).success!
          image_cache.commit(container_name)
        ensure
          ::FileUtils.remove_entry_secure(homedir)
          image_cache.rm(container_name)
          freeze
        end
      end
    end

    private

    attr_reader :image_cache, :mutex

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

    def container_name
      @container_name ||= image_cache.generate_container_name(image, setup_cli)
    end

    def build_container_cli(commands)
=begin
      script = <<~SCRIPT
      #!/bin/bash
      set -x
      #{commands.join("\n")}
      SCRIPT
      ::File.open(::Pathname.new(homedir).join('script'), 'w') { |file| file.write(script) }
=end
      <<~CLI
        #{executable} run --name #{container_name} --entrypoint /bin/bash --workdir #{mounts[workdir]} #{mount_cli} #{envs_cli} #{limits.to_cli} #{image_cache.image(container_name, image)} -c "#{commands.join(' && ')}"
      CLI
    end
  end
end
