# frozen_string_literal: true

module Broadcasts
  class Repository < ::Broadcasts::BaseBroadcast
    def update # rubocop: disable Metrics/MethodLength
      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        model,
        target: dom_id(model, :publishing_status),
        partial: 'repositories/publishing_status',
        locals: { repository: model }
      )

      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        model,
        target: dom_id(model, :show),
        partial: 'repositories/repository_show',
        locals: { repository: model }
      )
    end

    def destroy
      ::Turbo::StreamsChannel.broadcast_remove_to(:repositories, target: dom_id(model))
    end
  end
end
