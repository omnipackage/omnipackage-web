# frozen_string_literal: true

module RepoManage
  class Runtime
    attr_reader :executable, :workdir, :image

    def initialize(workdir:, image:, executable: 'podman')
      @executable = executable
      @workdir = workdir
      @image = image
    end

    def execute(cli)
      case executable
      when 'native'
        ::ShellUtil.execute(cli, chdir: workdir)
      when 'podman', 'docker'
        fcli = <<~CLI
        #{executable} run --rm --entrypoint /bin/sh --workdir #{mounts[workdir]} #{mount_cli} #{image} -c "#{cli}"
        CLI
        ::ShellUtil.execute(fcli)
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
