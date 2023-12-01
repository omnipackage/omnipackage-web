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
      ::Turbo::StreamsChannel.broadcast_update_later_to(
        :agents,
        target: 'public_agents_online_count',
        html: ::Agent.public_shared.online.count.to_s
      )

      ::Turbo::StreamsChannel.broadcast_update_later_to(
        :agents,
        target: 'public_agents_busy_count',
        html: ::Agent.public_shared.busy.count.to_s
      )
    end
  end
end
