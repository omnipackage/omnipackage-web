# frozen_string_literal: true

class InboundWebhooksController < ::ActionController::Base # rubocop: disable Rails/ApplicationController
  before_action :set_error_context
  skip_before_action :verify_authenticity_token
  before_action :verify!

  def trigger
    ::Task.start(webhook.project)
    head(:ok)
  rescue ::ActiveRecord::RecordInvalid
    head(:unprocessable_entity)
  end

  private

  def verify!
    head(:unauthorized) unless webhook.verify(request)
  end

  def webhook
    @webhook ||= ::Webhook.find_by!(key: params[:key])
  end

  def set_error_context
    ::Rails.error.set_context(request: request)
  end
end
