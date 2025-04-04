class InboundWebhooksController < ::ActionController::Base # rubocop: disable Rails/ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify!

  def trigger
    ::Task::Starter.new(webhook.project).call(sources_fetch_delay: 20.seconds)
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
end
