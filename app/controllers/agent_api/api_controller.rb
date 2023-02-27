# frozen_string_literal: true

module AgentApi
  class ApiController < ::ActionController::Base # rubocop: disable Rails/ApplicationController
    before_action :authorize
    skip_before_action :verify_authenticity_token
    rescue_from ::StandardError, with: :respond_error

    def call
      url_methods = ::Task::Scheduler::UrlMethods.new(method(:project_download_tarball_url))
      scheduler = ::Task::Scheduler.new(current_agent, url_methods)
      response_payload = scheduler.call(params.fetch(:payload))
      respond(response_payload)
    end

    private

    attr_reader :current_agent

    def respond(payload)
      response.set_header('X-NEXT-POLL-AFTER-SECONDS', 20)
      if payload
        render(json: payload)
      else
        head(:ok)
      end
    end

    def authorize
      @current_agent = ::Agent.find_by!(apikey: request.headers['X-APIKEY'] || params[:apikey])
    end

    def respond_error(exception)
      payload = { error: exception.message }
      # payload[:backtrace] = exception.backtrace if ::Rails.env.local?
      render(json: payload, status: :unprocessable_entity)
    end
  end
end
