# frozen_string_literal: true

module RepoManage
  class Runtime
    class ImageCache
      attr_reader :executable

      def initialize(executable:)
        @executable = executable
      end

      def generate_container_name(default_image, setup_cli)
        d = default_image.gsub(/[^0-9a-z]/i, '_')
        "omnipackage-web-#{d}-#{::Digest::SHA1.hexdigest(setup_cli.sort.join)}"
      end

      def image(container_name, default_image)
        if exists?(container_name)
          container_name
        else
          default_image
        end
      end

      def exists?(image)
        ::ShellUtil.execute("#{executable} image inspect #{image}").success?
      end

      def commit(container_name)
        ::ShellUtil.execute("#{executable} commit #{container_name} #{container_name}").success!
      end

      def rm(container_name)
        ::ShellUtil.execute("#{executable} rm -f #{container_name}").success!
      end
    end
  end
end
