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

    def initialize(runtime:, gpg_key: ::Gpg.new.generate_keys('Oleg', 'oleg@omnipackage.org'))
      @runtime = runtime
      @gpg_key = gpg_key
    end

    def call
      runtime.setup
      import_gpg_key
      refresh
      runtime.finalize
    end

    private

    def refresh
    end

    def import_gpg_key
      write_file(::Pathname.new(homedir).join('key.priv'), gpg_key.priv)
      write_file(::Pathname.new(homedir).join('key.pub'), gpg_key.pub)

      commands = [
        'gpg --import /root/key.priv',
        'gpg --show-keys /root/key.priv > /root/showkeys'
      ]
      runtime.execute(commands).success!
    end

    def gpg_key_id
      ::File.read(::Pathname.new(homedir).join('showkeys')).lines[1].strip
    end

    def write_file(path, content)
      ::File.open(path, 'w') do |file|
        file.write(content)
      end
    end
  end
end
