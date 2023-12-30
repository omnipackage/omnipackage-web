# frozen_string_literal: true

module RepoManage
  class Runtime
    attr_reader :executable, :workdir, :setup_cli, :homedir, :limits

    def initialize(workdir:, image:, setup_cli:, executable:, limits: ::RepoManage::Runtime::Limits.new) # rubocop: disable Metrics/MethodLength
      @executable = executable
      @workdir = workdir
      @setup_cli = setup_cli
      @homedir = ::Dir.mktmpdir
      @image_cache = ::RepoManage::Runtime::ImageCache.new(executable: executable, default_image: image, setup_cli: setup_cli)
      @limits = limits

      ::Rails.error.set_context(
        default_image:  image_cache.default_image,
        limits:         limits.inspect,
        container_name: image_cache.container_name
      )
    end

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

    def lockfile
      lockfiles_dir = ::Pathname.new(::Dir.tmpdir).join('omnipackage-lock')
      ::FileUtils.mkdir_p(lockfiles_dir.to_s)
      lock_key = image_cache.container_name.gsub(/[^0-9a-z]/i, '_')
      lockfiles_dir.join("#{lock_key}.lock")
    end

    def fix_permissions(commands)
      if executable == 'docker'
        commands.unshift('umask 000')
        mounts.each do |_from, to|
          commands << "chown -R #{::Process.uid}:#{::Process.gid} #{to}"
        end
      end
    end

    def build_container_cli(commands) # rubocop: disable Metrics/AbcSize
      fix_permissions(commands)

=begin
      script = <<~SCRIPT
      #!/bin/bash
      set -x
      #{commands.join("\n")}
      SCRIPT
      ::File.open(::Pathname.new(homedir).join('script'), 'w') { |file| file.write(script) }
=end

      <<~CLI
        flock --no-fork --timeout #{limits.execute_timeout + 30} #{lockfile} --command '#{image_cache.rm_cli} ; #{executable} run --name #{image_cache.container_name} --entrypoint /bin/bash --workdir #{mounts[workdir]} #{mount_cli} #{envs_cli} #{limits.to_cli} #{image_cache.image} -c "#{commands.join(' && ')}" && #{image_cache.commit_cli}'
      CLI
    end
  end
end
