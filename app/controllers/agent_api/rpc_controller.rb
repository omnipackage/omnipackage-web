# frozen_string_literal: true

module AgentApi
  class RpcController < ::ActionController::Base # rubocop: disable Rails/ApplicationController
    before_action :authorize
    rescue_from ::StandardError, with: :respond_error

    def call
      render(json: { hello: 1 })
    end

    private

    def respond_error(exception)
      render(json: { error: exception.message }, status: :unprocessable_entity)
    end

    def authorize
      ::Agent.find_by!(apikey: params[:apikey])
    end
  end
end
