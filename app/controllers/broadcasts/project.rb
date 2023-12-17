# frozen_string_literal: true

module Broadcasts
  class Project < ::Broadcasts::BaseBroadcast
    def update
      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        [model, :show],
        target: dom_id(model),
        template: 'projects/show',
        assigns: { project: model },
        layout: false
      )
      # ::Turbo::StreamsChannel.broadcast_render_later_to(
      #  model,
      #  partial: 'projects/stream',
      #  locals: { project: model },
      # )
    end
  end
end
