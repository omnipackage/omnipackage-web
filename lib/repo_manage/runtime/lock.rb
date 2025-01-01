module RepoManage
  class Runtime
    class Lock
      def initialize(key:, limits:, lockfiles_dir: ::Pathname.new(::Dir.tmpdir).join('omnipackage-lock'))
        @limits = limits
        @lockfile = build_lockfile(key, ::Pathname.new(lockfiles_dir))
      end

      def to_cli
        "flock --verbose --no-fork --timeout #{limits.execute_timeout + 30} #{lockfile} --command"
      end

      private

      attr_reader :lockfile, :limits

      def build_lockfile(key, lockfiles_dir)
        ::FileUtils.mkdir_p(lockfiles_dir.to_s)
        lock_key = key.gsub(/[^0-9a-z]/i, '_')
        lockfiles_dir.join("#{lock_key}.lock")
      end
    end
  end
end
