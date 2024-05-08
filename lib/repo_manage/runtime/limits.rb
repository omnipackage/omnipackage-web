# frozen_string_literal: true

module RepoManage
  class Runtime
    class Limits
      attr_reader :memory, :cpus, :execute_timeout, :pids

      def initialize(memory: '1000m', cpus: '1', pids: 1000, execute_timeout: 30.minutes.to_i)
        @memory = memory
        @cpus = cpus
        @execute_timeout = execute_timeout
        @pids = pids
      end

      def to_cli
        <<~CLI.squish
        --memory=#{memory} --cpus="#{cpus}" --pids-limit=#{pids}
        CLI
      end
    end
  end
end
