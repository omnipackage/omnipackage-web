# frozen_string_literal: true

module Broadcasts
  class Project < ::Broadcasts::BaseBroadcast
    def update
      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        model,
        target: dom_id(model),
        template: 'projects/show',
        assigns: { project: model },
        layout: false
      )
    end
  end
end
