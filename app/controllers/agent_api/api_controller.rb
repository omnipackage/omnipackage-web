# frozen_string_literal: true

module AgentApi
  class ApiController < ::ActionController::Base # rubocop: disable Rails/ApplicationController
    before_action :authorize
    skip_before_action :verify_authenticity_token
    rescue_from ::StandardError, with: :respond_error

    @@once = true

    def call # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
      scheduler = ::Task::Scheduler.new(current_agent)
      command = scheduler.call(params.fetch(:payload))

      next_poll_after = current_agent.next_poll_after

      response_hash = {}
      if params[:sequence].to_i <= 1 || @@once
        response_hash[:distro_configs] = ::Distro.load_from_file
        ::Rails.logger.info("Sending all distro configs to agent #{current_agent.id}")
        @@once = false
      end
      current_agent.touch_last_seen(next_poll_after)
      response.set_header('X-NEXT-POLL-AFTER-SECONDS', next_poll_after)

      if command.is_a?(::Task::Scheduler::Command)
        response_hash.merge!(command.to_hash(view_context))
      end

      if response_hash.empty?
        head(:ok)
      else
        render(json: response_hash)
      end
    end

    def sources_tarball
      sources_tarball = current_agent.tasks.find(params[:task_id]).sources_tarball
      send_data(sources_tarball.decrypted_tarball, filename: sources_tarball.decrypted_tarball_filename)
    end

    def upload_artefact # rubocop:disable Metrics/AbcSize
      task = current_agent.tasks.find(params[:task_id])
      blob = ::ActiveStorage::Blob.create_and_upload!(
        io:           params[:data],
        filename:     params[:data].original_filename,
        content_type: params[:data].content_type
      )
      task.artefacts.create!(attachment: blob, distro: params[:distro])
      # render json: { filelink: url_for(blob) }
      head(:ok)
    end

    private

    attr_reader :current_agent

    def authorize
      apikey = request.headers['Authorization']&.delete('Bearer: ') || params[:apikey]
      @current_agent = ::Agent.find_by(apikey: apikey)
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
