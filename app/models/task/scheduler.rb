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

    def schedule # rubocop: disable Metrics/MethodLength
      ::ApplicationRecord.transaction(isolation: :serializable) do
        task = atomic_task_fetch
        raise ::ActiveRecord::Rollback unless task

        {
          command: 'start',
          task: {
            id: task.id,
            sources_tarball_url: url_methods.tarball_url.call(task.id)
          }
        }
      end
    end

    def atomic_task_fetch # rubocop: disable Metrics/MethodLength
      sql = <<~SQL.squish
        UPDATE
          tasks
        SET
          state = 'running',
          agent_id = #{agent.id}
        WHERE id = (
          SELECT t.id FROM tasks t
          JOIN project_sources_tarballs pst ON t.sources_tarball_id = pst.id
          JOIN projects p ON pst.project_id = p.id
          JOIN agents a ON (p.user_id = a.user_id OR a.user_id ISNULL)
          WHERE t.state = 'scheduled' AND a.id = #{agent.id}
          ORDER BY t.created_at ASC LIMIT 1
          FOR UPDATE
        ) RETURNING *;
      SQL
      pgresult = ::ApplicationRecord.connection.execute(sql)
      return if pgresult.values.empty?

      fields = pgresult.fields
      ::Task.instantiate(fields.zip(pgresult.values.sole).to_h)
    end

    def busy(task_payload)
      task = agent.tasks.find(task_payload.fetch(:id))
      ::ApplicationRecord.transaction do
        task.running!
      end
      nil
    end

    def finish(task_payload)
      task = agent.tasks.find(task_payload.fetch(:id))
      ::ApplicationRecord.transaction do
        task.finished!
      end
      nil
    end
  end
end
