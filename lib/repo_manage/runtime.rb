# frozen_string_literal: true

module RepoManage
  class Runtime
    attr_reader :executable, :workdir, :image, :setup_cli

    def initialize(workdir:, image:, setup_cli:, executable:)
      @executable = executable
      @workdir = workdir
      @image = image
      @setup_cli = setup_cli
    end

    def execute(cli)
      case executable
      when 'native'
        ::ShellUtil.execute(cli, chdir: workdir).success!
      when 'podman', 'docker'
        execute_in_container(cli)
      else
        raise "unknown runtime: #{executable}"
      end
    end

    private

    def mounts
      { workdir => '/workdir' }
    end

    def mount_cli
      mounts.map do |from, to|
        "--mount type=bind,source=#{from},target=#{to}"
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

    def build_container_cli(cli)
      commands = setup_cli + [cli]
      <<~CLI
        #{executable} run --name #{container_name} --entrypoint /bin/sh --workdir #{mounts[workdir]} #{mount_cli} #{image_to_run} -c "#{commands.join(' && ')}"
      CLI
    end

    def execute_in_container(cli)
      ::ShellUtil.execute(build_container_cli(cli), timeout_sec: 600).success!
      image_cache.commit(container_name)
    ensure
      image_cache.rm(container_name)
    end
  end
end
