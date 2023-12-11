# frozen_string_literal: true

class InboundWebhooksController < ::ActionController::Base # rubocop: disable Rails/ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify!

  def trigger
    if ::Task.new(project: webhook.project).save
      head(:ok)
    else
      head(:unprocessable_entity)
    end
  end

  private

  def verify!
    head(:unauthorized) unless webhook.verify(request)
  end

  def webhook
    @webhook ||= ::Webhook.find_by!(key: params[:key])
  end
end
