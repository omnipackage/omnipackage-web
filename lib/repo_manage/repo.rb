# frozen_string_literal: true

module RepoManage
  class Repo
    class << self
      def new(**kwargs)
        case kwargs.fetch(:type).to_s
        when 'rpm'
          ::RepoManage::Repo::Rpm
        when 'deb'
          ::RepoManage::Repo::Deb
        else
          raise "unknown repo type: #{kwargs}"
        end.allocate.tap { |o| o.send(:initialize, **kwargs.except(:type)) }
      end
    end

    attr_reader :runtime, :type, :gpg_key

    delegate :workdir, :homedir, to: :runtime

    def initialize(runtime:, gpg_key:)
      @runtime = runtime
      @gpg_key = gpg_key
    end

    def call
      write_gpg_keys
      refresh
    end

    def write_rpm_repo_file(*)
    end

    private

    def refresh
    end

    def write_gpg_keys
      write_file(::Pathname.new(homedir).join('key.priv'), gpg_key.priv)
      write_file(::Pathname.new(workdir).join('public.key'), gpg_key.pub)
    end

    def gpg_key_id
      ::Gpg.new.key_id(::Pathname.new(homedir).join('key.priv').to_s)
    end

    def import_gpg_keys_commands
      [
        'gpg --no-tty --batch --import /root/key.priv',
        'gpg --no-tty --batch --import public.key'
      ]
    end

    def write_file(path, content)
      ::File.open(path, 'w') do |file|
        file.write(content)
      end
    end
  end
end
