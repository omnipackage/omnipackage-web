# frozen_string_literal: true

class Agent
  module Api
    class Process
      attr_reader :agent, :url_methods

      UrlMethods = ::Data.define(:project_download_tarball_url)

      def initialize(agent, url_methods)
        @agent = agent
        @url_methods = url_methods
      end

      def call(payload)
        case payload.fetch(:status)
        when 'idle'
          schedule
        when 'busy'
          agent_task = agent.agent_tasks.find(payload.fetch(:agent_task_id))
          touch(agent_task)
        when 'done'
          agent_task = agent.agent_tasks.find(payload.fetch(:agent_task_id))
          finish(agent_task)
        else
          raise "unknown status #{payload[:status]}"
        end
      end

      private

      def schedule
        ::ApplicationRecord.transaction(isolation: :serializable) do
          task = atomic_task_fetch
          return unless task
          agent_task = agent.agent_tasks.create!(task: task, state: 'scheduled')
          {
            command: 'start',
            agent_task_id: agent_task.id,
            sources_tarball_url: url_methods.project_download_tarball_url.call(task.project.id)
          }
        end
      end

      def atomic_task_fetch
        sql = <<~SQL
        UPDATE
          tasks
        SET
          state = 'running'
        WHERE id = (
          SELECT id FROM tasks WHERE state = 'fresh' ORDER BY created_at ASC LIMIT 1 FOR UPDATE
        ) RETURNING *;
        SQL
        pgresult = ::ApplicationRecord.connection.execute(sql)
        return if pgresult.values.empty?
        fields = pgresult.fields
        ::Task.instantiate(::Hash[fields.zip(pgresult.values.sole)])
      end

      def touch(agent_task)
        ::ApplicationRecord.transaction do
          # TODO: read log
          agent_task.touch
          agent_task.task.touch
        end
      end

      def finish(agent_task)
        ::ApplicationRecord.transaction do
          agent_task.done!
          agent_task.task.finished!
        end
      end
    end
  end
end
