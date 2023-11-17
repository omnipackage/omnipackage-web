# frozen_string_literal: true

class Project
  class Sources
    class Git < ::Project::Sources
      def initialize(**kwargs)
        super
        ssh_private_key = kwargs.fetch(:ssh_private_key)
        @git = ::Git.new(ssh_private_key: ssh_private_key)
      end

      def probe
        git.ping(location)
      end

      def clone
        dir = ::Dir.mktmpdir
        return unless git.clone(location, dir)

        if block_given?
          yield(::Pathname.new(dir).join(subdir).to_s)
        else
          true
        end
      ensure
        ::FileUtils.remove_entry(dir)
      end

      private

      attr_reader :git

      def tarball_excludes
        %w[.git]
      end
    end
  end
end
