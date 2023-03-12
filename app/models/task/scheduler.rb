# frozen_string_literal: true

class Task
  class Scheduler
    attr_reader :agent

    Command = ::Data.define(:command, :task) do
      def to_hash(view_context)
        result = { command: command }
        result[:task] = {
          id:                   task.id,
          sources_tarball_url:  view_context.agent_api_download_sources_tarball_url(task.id)
        } if task
        result.freeze
      end
    end

    def initialize(agent)
      @agent = agent
    end

    def call(payload)
      state = payload.fetch(:state)
      return schedule if state == 'idle'

      task = agent.tasks.find_by(id: payload.fetch(:task).fetch(:id))
      return Command['stop', nil] unless task

      if state == 'busy'
        busy(task)
      elsif state == 'finished'
        finish(task)
      end
    end

    private

    def schedule
      ::ApplicationRecord.transaction(isolation: :serializable) do
        task = atomic_task_fetch
        raise ::ActiveRecord::Rollback unless task

        Command['start', task]
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

    def busy(task)
      ::ApplicationRecord.transaction do
        task.running!
      end
    end

    def finish(task)
      ::ApplicationRecord.transaction do
        task.finished!
      end
    end
  end
end
