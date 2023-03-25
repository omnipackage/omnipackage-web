# frozen_string_literal: true

module AgentApi
  class ApiController < ::ActionController::Base # rubocop: disable Rails/ApplicationController
    before_action :authorize
    skip_before_action :verify_authenticity_token
    rescue_from ::StandardError, with: :respond_error

    def call
      scheduler = ::Task::Scheduler.new(current_agent)
      command = scheduler.call(params.fetch(:payload))

      next_poll_after = current_agent.next_poll_after
      current_agent.touch_last_seen(next_poll_after)
      response.set_header('X-NEXT-POLL-AFTER-SECONDS', next_poll_after)
      if command.is_a?(::Task::Scheduler::Command)
        render(json: command.to_hash(view_context))
      else
        head(:ok)
      end
    end

    def sources_tarball
      sources_tarball = current_agent.tasks.find(params[:task_id]).sources_tarball
      send_data(sources_tarball.decrypted_tarball, filename: sources_tarball.decrypted_tarball_filename)
    end

    def upload_artefact
      task = current_agent.tasks.find(params[:task_id])
      blob = ::ActiveStorage::Blob.create_and_upload!(
        io:           params[:data],
        filename:     params[:data].original_filename,
        content_type: params[:data].content_type
      )
      task.artefacts.attach(blob)
      # render json: { filelink: url_for(blob) }
      head(:ok)
    end

    private

    attr_reader :current_agent

    def authorize
      @current_agent = ::Agent.find_by(apikey: request.headers['X-APIKEY'] || params[:apikey])
      head(:unauthorized) unless current_agent
    end

    def respond_error(exception)
      payload = { error: exception.message }
      ::Rails.logger.error(exception.message)
      ::Rails.logger.error(exception.backtrace)
      # payload[:backtrace] = exception.backtrace if ::Rails.env.local?
      render(json: payload, status: :unprocessable_entity)
    end
  end
end
