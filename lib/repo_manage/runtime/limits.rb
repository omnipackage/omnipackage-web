# frozen_string_literal: true

module RepoManage
  class Runtime
    class Limits
      attr_reader :memory, :cpus

      def initialize(memory: '200m', cpus: '0.5')
        @memory = memory
        @cpus = cpus
      end

      def to_cli
        <<~CLI.squish
        --memory=#{memory} --cpus="#{cpus}"
        CLI
      end
    end
  end
end
