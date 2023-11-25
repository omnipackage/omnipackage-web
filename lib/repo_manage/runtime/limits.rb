# frozen_string_literal: true

module RepoManage
  class Runtime
    class Limits
      attr_reader :memory, :cpus, :execute_timeout

      def initialize(memory: '500m', cpus: '0.5', execute_timeout: 30.minutes.to_i)
        @memory = memory
        @cpus = cpus
        @execute_timeout = execute_timeout
      end

      def to_cli
        <<~CLI.squish
        --memory=#{memory} --cpus="#{cpus}"
        CLI
      end
    end
  end
end
