# frozen_string_literal: true

module Broadcasts
  class Project < ::Broadcasts::BaseBroadcast
    def update # rubocop: disable Metrics/MethodLength
      ::Turbo::StreamsChannel.broadcast_update_later_to(
        model,
        target: dom_id(model),
        partial: 'projects/project_show',
        locals: { project: model }
      )

      ::Turbo::StreamsChannel.broadcast_update_later_to(
        model.user,
        target: dom_id(model),
        partial: 'projects/project',
        locals: { project: model }
      )
    end
  end
end
