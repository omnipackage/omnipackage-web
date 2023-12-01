# frozen_string_literal: true

class AgentStatusCheckJob < ::ApplicationJob
  queue_as :default

  def perform(agent_id)
    agent = ::Agent.find(agent_id)
    if agent.offline?
      ::Broadcasts::Agent.new(agent).update
    end
  end
end
