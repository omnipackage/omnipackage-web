# frozen_string_literal: true

module Broadcasts
  class Agent < ::Broadcasts::BaseBroadcast
    def create
      refresh_public_agents_count
    end

    def update
      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        [model.user, :agents],
        target: dom_id(model),
        partial: 'agents/agent',
        locals: { agent: model }
      )
      refresh_public_agents_count
    end

    def destroy
      refresh_public_agents_count
    end

    private

    def refresh_public_agents_count
      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        :agents,
        target: 'public_agents_summary',
        partial: 'agents/public_agents_summary'
      )
    end
  end
end
