# frozen_string_literal: true

module Broadcasts
  class Repository < ::Broadcasts::BaseBroadcast
    def update # rubocop: disable Metrics/MethodLength
      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        [model.project, model],
        target: dom_id(model),
        partial: 'projects/repo',
        locals: { repository: model }
      )

      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        [model, :show],
        target: dom_id(model),
        template: 'repositories/show',
        assigns: { repository: model },
        layout: false
      )
    end

    def destroy
      ::Turbo::StreamsChannel.broadcast_remove_to(:repositories, target: dom_id(model))
    end
  end
end
