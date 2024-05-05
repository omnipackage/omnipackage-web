# frozen_string_literal: true

module Broadcasts
  class Agent < ::Broadcasts::BaseBroadcast
    def update
      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        model.user,
        target: dom_id(model),
        partial: 'agents/agent',
        locals: { agent: model }
      )
    end
  end
end
