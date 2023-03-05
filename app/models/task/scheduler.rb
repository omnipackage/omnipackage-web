# frozen_string_literal: true

class Task
  class Scheduler
    attr_reader :agent, :url_methods

    UrlMethods = ::Data.define(:tarball_url)

    def initialize(agent, url_methods)
      @agent = agent
      @url_methods = url_methods
    end

    def call(payload)
      case payload.fetch(:state)
      when 'idle'
        schedule
      when 'busy'
        busy(payload.fetch(:task))
      when 'finished'
        finish(payload.fetch(:task))
      else
        raise "unknown state #{payload[:state]}"
      end
    end

    private

    def schedule
      ::ApplicationRecord.transaction(isolation: :serializable) do
        task = atomic_task_fetch
        raise ::ActiveRecord::Rollback unless task

        agent_task = agent.agent_tasks.create!(task: task, state: 'scheduled')
        {
          command: 'start',
          task: {
            id: agent_task.id,
            sources_tarball_url: url_methods.tarball_url.call(agent_task.id)
          }
        }
      end
    end

    def atomic_task_fetch # rubocop: disable Metrics/MethodLength
      sql = <<~SQL.squish
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
      ::Task.instantiate(fields.zip(pgresult.values.sole).to_h)
    end

    def busy(task_payload)
      agent_task = agent.agent_tasks.find(task_payload.fetch(:id))
      ::ApplicationRecord.transaction do
        # TODO: read log
        agent_task.touch # rubocop: disable Rails/SkipsModelValidations
        agent_task.task.touch # rubocop: disable Rails/SkipsModelValidations
      end
      nil
    end

    def finish(task_payload)
      agent_task = agent.agent_tasks.find(task_payload.fetch(:id))
      ::ApplicationRecord.transaction do
        agent_task.done!
        agent_task.task.finished!
      end
      nil
    end
  end
end
