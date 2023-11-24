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
    end

    def execute(commands, timeout_sec: 30.minutes.to_i)
      raise 'execute can only be used once' if frozen?

      ::ShellUtil.execute(build_container_cli(setup_cli + commands), timeout_sec: timeout_sec).success!
      image_cache.commit(container_name)
    ensure
      image_cache.rm(container_name)
      ::FileUtils.remove_entry_secure(homedir)
      freeze
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
