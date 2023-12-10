# frozen_string_literal: true

class InboundWebhooksController < ::ActionController::Base # rubocop: disable Rails/ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify!

  def trigger
    if ::Task.new(project: @webhook.project).save
      head(:ok)
    else
      head(:unprocessable_entity)
    end
  end

  private

  def verify!
    @webhook = ::Webhook.find_by!(key: params[:key])

    if @webhook.secret
      request.body.rewind

      github_signature = request.headers['X-Hub-Signature-256']
      return if github_signature && @webhook.verify_github(request.body.read, github_signature)

      head(:unauthorized)
    end
  end
end
