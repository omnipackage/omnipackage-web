# frozen_string_literal: true

module RepoManage
  class Runtime
    attr_reader :executable, :workdir, :image, :setup_cli, :homedir

    def initialize(workdir:, image:, setup_cli:, executable:)
      @executable = executable
      @workdir = workdir
      @image = image
      @setup_cli = setup_cli
      @homedir = ::Dir.mktmpdir
    end

    def setup
      execute(setup_cli, timeout_sec: 600)
    end

    def execute(commands, timeout_sec: 60)
      raise 'the runtime has been already finalized' if frozen?

      ::ShellUtil.execute(build_container_cli(commands), timeout_sec: timeout_sec).success!
      image_cache.commit(container_name)
    ensure
      image_cache.rm(container_name)
    end

    def finalize
      ::FileUtils.remove_entry_secure(homedir)
      freeze
    end

    private

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

    def image_cache
      @image_cache ||= ::RepoManage::Runtime::ImageCache.new(executable: executable)
    end

    def container_name
      @container_name ||= image_cache.generate_container_name(image, setup_cli)
    end

    def image_to_run
      @image_to_run ||= image_cache.image(container_name, image)
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
        #{executable} run --name #{container_name} --entrypoint /bin/bash --workdir #{mounts[workdir]} #{mount_cli} #{envs_cli} #{image_to_run} -c "#{commands.join(' && ')}"
      CLI
    end
  end
end
