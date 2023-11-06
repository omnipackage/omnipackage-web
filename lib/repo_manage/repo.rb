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

    attr_reader :directory, :runtime, :type

    def initialize(directory:, runtime:)
      @directory = directory
      @runtime = runtime
    end

    def refresh
    end
  end
end
