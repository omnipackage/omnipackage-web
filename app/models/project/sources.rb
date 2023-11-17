# frozen_string_literal: true

class Project
  class Sources
    class << self
      def new(**kwargs) # rubocop: disable Metrics/MethodLength
        case kwargs.fetch(:kind)
        when 'git'
          ::Project::Sources::Git
        when 'localfs'
          raise 'only available in local envs' unless ::Rails.env.local?

          ::Project::Sources::Localfs
        else
          raise "unsupported sources kind '#{kwargs}'"
        end.allocate.tap { |o| o.send(:initialize, **kwargs.except(:kind)) }
      end
    end

    Envelop = ::Data.define(:config, :tarball)

    attr_reader :location, :subdir

    def initialize(**kwargs)
      @location = kwargs.fetch(:location)
      @subdir = kwargs.fetch(:subdir, '')
      raise "forbidden subdir '#{subdir}'" if subdir.start_with?('/') || subdir.include?('..')
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
      ::YAML.load_file(::File.join(dir, '.omnipackage', 'config.yml'), aliases: true)
    end

    def tarball_excludes
      %w[.git]
    end
  end
end
