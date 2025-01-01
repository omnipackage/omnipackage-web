class Task
  class Scheduler # rubocop: disable Metrics/ClassLength
    attr_reader :agent

    Command = ::Data.define(:command, :task) do
      def to_hash(view_context) # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
        result = { command: command }
        if task
          result[:task] = {
            id:                   task.id,
            sources_tarball_url:  task.sources.url(expires_in: 3.days),
            upload_artefact_url:  view_context.agent_api_upload_artefact_url(task.id),
            distros:              task.distro_ids,
            limits:               task.agent_limits,
            secrets:              task.secrets
          }
        end
        result.freeze
      end
    end

    def initialize(agent)
      @agent = agent
    end

    def call(payload) # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
      state = payload.fetch(:state)

      if state == 'idle'
        reschedule
        return schedule
      end

      log = payload[:livelog]
      stats = payload[:stats]
      task_id = payload.fetch(:task).fetch(:id)

      task = agent.tasks.find_by(id: task_id)
      return stop_command if !task

      if task.cancelled?
        save_log_stats(task, log, stats)
        return stop_command
      end

      if state == 'busy'
        busy(task, log)
      elsif state == 'finished'
        finish(task, log, stats)
      end
    end

    private

    def stop_command
      Command['stop', nil]
    end

    def schedule
      ::ApplicationRecord.transaction(isolation: :serializable) do
        task = atomic_task_fetch
        if task
          Command['start', task]
        else
          raise ::ActiveRecord::Rollback
        end
      end
    end

    def atomic_task_fetch # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
      sql = <<~SQL.squish
        UPDATE
          tasks
        SET
          state = 'running',
          agent_id = #{agent.id},
          started_at = NOW() at time zone 'utc'
        WHERE id = (
          SELECT t.id FROM tasks t
          JOIN projects p ON t.project_id = p.id
          JOIN agents a ON (p.user_id = a.user_id OR a.user_id ISNULL)
          WHERE
            t.state = 'pending_build' AND
            a.id = #{agent.id} AND
            t.distro_ids::varchar[] && ARRAY[#{agent.supported_distros.map { |d| "'#{d.id}'" }.join(',')}]::varchar[]
          ORDER BY t.created_at ASC LIMIT 1
          FOR UPDATE
        ) RETURNING *;
      SQL
      pgresult = ::ApplicationRecord.connection.execute(sql)
      return if pgresult.values.empty?

      fields = pgresult.fields
      ::Task.instantiate(fields.zip(pgresult.values.sole).to_h)
    end

    def reschedule
      # agent restarted or something else happened that it's no idle, but has running tasks
      if agent.tasks.running.exists?
        agent.reschedule_all_tasks!
      end
    end

    def busy(task, log)
      ::ApplicationRecord.transaction do
        task.append_log(log)
        task.running!
      end
    end

    def finish(task, log, stats)
      ::ApplicationRecord.transaction do
        task.append_log(log)
        task.save_stats(stats)
        task.finish!
      end
      ::RepositoryPublishJob.start(task)
    end

    def save_log_stats(task, log, stats)
      ::ApplicationRecord.transaction do
        task.append_log(log) if log
        task.save_stats(stats) if stats
      end
    end
  end
end
