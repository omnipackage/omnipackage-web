# frozen_string_literal: true

module AgentApi
  class ApiController < ::ActionController::Base # rubocop: disable Rails/ApplicationController
    before_action :authorize
    skip_before_action :verify_authenticity_token
    rescue_from ::StandardError, with: :respond_error

    def call
      url_methods = ::Agent::Api::Process::UrlMethods.new(method(:project_download_tarball_url))
      process = ::Agent::Api::Process.new(current_agent, url_methods)
      response_payload = process.call(params[:payload])
      if response_payload
        render(json: response_payload)
      else
        head(:ok)
      end
    end

    private

    attr_reader :current_agent

    def authorize
      @current_agent = ::Agent.find_by!(apikey: params[:apikey])
    end

    def respond_error(exception)
      payload = { error: exception.message }
      #payload[:backtrace] = exception.backtrace if ::Rails.env.local?
      render(json: payload, status: :unprocessable_entity)
    end
  end
end
