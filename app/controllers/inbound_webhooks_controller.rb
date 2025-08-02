class InboundWebhooksController < ::ActionController::Base # rubocop: disable Rails/ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify!

  def trigger
    ::AsyncTaskStarterJob.perform_later(webhook.project_id)
    head(:ok)
  rescue ::ActiveRecord::RecordInvalid
    head(:unprocessable_content)
  end

  private

  def verify!
    head(:unauthorized) unless webhook.verify(request)
  end

  def webhook
    @webhook ||= ::Webhook.find_by!(key: params[:key])
  end
end
