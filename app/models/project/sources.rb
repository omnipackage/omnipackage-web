class Project
  class Sources
    class << self
      def new(**kwargs)
        kind = kwargs.delete(:kind)
        raise "unsupported sources kind '#{kwargs}'" unless kinds.include?(kind)

        klass(kind).allocate.tap { |o| o.send(:initialize, **kwargs) }
      end

      def kinds
        i = %w[git]
        i << 'localfs' if ::Rails.env.local?
        i.freeze
      end

      private

      def klass(kind)
        ::Project::Sources.const_get(kind.camelize, false)
      end
    end

    Envelop = ::Data.define(:config, :tarball)

    attr_reader :location, :subdir, :config_path

    def initialize(**kwargs)
      @location = kwargs.fetch(:location)
      @subdir = kwargs.fetch(:subdir, '')
      @config_path = kwargs[:config_path].presence || '.omnipackage/config.yml'
      raise "forbidden subdir '#{subdir}'" if subdir.start_with?('/') || subdir.include?('..')
    end

    def sync
      clone do |dir|
        tarball = ::Tempfile.new
        ::ShellUtil.compress(dir, tarball.path, excludes: tarball_excludes)
        Envelop[read_config(dir), tarball]
      end
    end

    def probe
    end

    def clone
    end

    private

    def read_config(dir)
      path = ::File.join(dir, config_path)
      raise "file '#{config_path}' does not exist" unless ::File.exist?(path)

      ::YAML.load_file(path, aliases: true)
    end

    def tarball_excludes
      %w[.git]
    end
  end
end
