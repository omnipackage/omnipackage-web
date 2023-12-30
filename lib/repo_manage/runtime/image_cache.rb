# frozen_string_literal: true

module RepoManage
  class Runtime
    class ImageCache
      attr_reader :executable, :container_name, :default_image

      def initialize(executable:, default_image:, setup_cli:)
        @executable = executable
        @default_image = default_image
        @container_name = generate_container_name(default_image, setup_cli)
      end

      def image
        if ::ShellUtil.execute("#{executable} image inspect #{container_name}").success?
          container_name
        else
          default_image
        end
      end

      def commit_cli
        "#{executable} commit #{container_name} #{container_name}"
      end

      def rm_cli
        "#{executable} rm -f #{container_name}"
      end

      private

      def generate_container_name(default_image, setup_cli)
        d = default_image.gsub(/[^0-9a-z]/i, '_')
        "omnipackage-web-#{d}-#{::Digest::SHA1.hexdigest(setup_cli.sort.join)}"
      end
    end
  end
end
