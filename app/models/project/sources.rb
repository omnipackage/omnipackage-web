# frozen_string_literal: true

class Project
  class Sources
    class << self
      def new(kind:, location:, ssh_private_key: nil) # rubocop: disable Metrics/MethodLength
        case kind
        when 'git'
          ::Project::Sources::Git.allocate.tap do |o|
            o.send(:initialize, location: location, ssh_private_key: ssh_private_key)
          end
        when 'localfs'
          raise 'only available in local envs' unless ::Rails.env.local?

          ::Project::Sources::Localfs.allocate.tap do |o|
            o.send(:initialize, location: location)
          end
        else
          raise "unsupported sources kind '#{kind}'"
        end
      end
    end

    Envelop = ::Data.define(:config, :tarball)

    attr_reader :location

    def initialize(location:)
      @location = location
    end

    def sync
      clone do |dir|
        tarball = ::ShellUtil.compress_and_encrypt(dir, passphrase: ::Rails.application.credentials.sources_tarball_passphrase, excludes: tarball_excludes)
        # ::File.open('/home/oleg/Desktop/ololo.tar.xz.gpg', 'wb') { |file| file.write(out) }
        Envelop[read_config(dir), tarball]
      end
    end

    def probe
    end

    def clone
    end

    private

    def read_config(dir)
      ::YAML.load_file(::File.join(dir, '.omnipackage', 'config.yml'))
    end

    def tarball_excludes
      %w[.git]
    end
  end
end
