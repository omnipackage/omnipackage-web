# frozen_string_literal: true

module Broadcasts
  class Repository < ::Broadcasts::BaseBroadcast
    def update # rubocop: disable Metrics/MethodLength
      ::Turbo::StreamsChannel.broadcast_update_later_to(
        model,
        target: dom_id(model),
        partial: 'repositories/repository_show',
        locals: { repository: model }
      )

      ::Broadcasts::Project.new(model.project).update
    end

    def destroy
      ::Turbo::StreamsChannel.broadcast_remove_to(:repositories, target: dom_id(model))
    end
  end
end
