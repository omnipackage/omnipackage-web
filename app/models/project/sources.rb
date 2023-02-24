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

    Envelop = ::Data.define(:config, :tarball)

    attr_reader :location

    def initialize(location:)
      @location = location
    end

    def sync
      clone do |dir|
        conf = ::YAML.load_file(::File.join(dir, '.omnipackage', 'config.yml'))
        tarball = ::ShellUtil.compress_and_encrypt(dir, passphrase: ::Rails.application.credentials.sources_tarball_passphrase, excludes: tarball_excludes)
        # ::File.open('/home/oleg/Desktop/ololo.tar.xz.gpg', 'wb') { |file| file.write(out) }
        Envelop[conf, tarball]
      end
    end

    def probe
    end

    def clone
    end

    private

    def tarball_excludes
      []
    end
  end
end
