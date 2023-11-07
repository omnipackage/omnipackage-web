# frozen_string_literal: true

module RepoManage
  class Runtime
    attr_reader :executable, :workdir, :image, :setup_cli

    def initialize(workdir:, image:, setup_cli:, executable: 'podman')
      @executable = executable
      @workdir = workdir
      @image = image
      @setup_cli = setup_cli
    end

    def execute(cli)
      case executable
      when 'native'
        ::ShellUtil.execute(cli, chdir: workdir)
      when 'podman', 'docker'
        commands = setup_cli + [cli]
        fcli = <<~CLI
          #{executable} run --rm --entrypoint /bin/sh --workdir #{mounts[workdir]} #{mount_cli} #{image} -c "#{commands.join(' && ')}"
        CLI
        ::ShellUtil.execute(fcli, timeout_sec: 3000)
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
  end
end
