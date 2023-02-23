# frozen_string_literal: true

class Project
  class Sources
    class << self
      def new(kind:, location:, ssh_private_key:)
        case kind
        when 'git'
          ::Project::Sources::Git.allocate.tap do |o|
            o.send(:initialize, location: location, ssh_private_key: ssh_private_key)
          end
        else
          raise "unsupported sources kind '#{kind}'"
        end
      end
    end

    attr_reader :location

    def initialize(location:)
      @location = location
    end

    def build_config
      clone do |dir|
        ::YAML.load_file(::File.join(dir, '.omnipackage', 'config.yml'), aliases: true)
      end
    end

    def probe
    end

    def clone
    end
  end
end
