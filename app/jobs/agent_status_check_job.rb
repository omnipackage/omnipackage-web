# frozen_string_literal: true

class AgentStatusCheckJob < ::ApplicationJob
  queue_as :default

  def perform
    ::Agent.offline.find_each do |agent|
      ::Rails.error.handle do
        agent.reschedule_all_tasks!
      end
    end
  end
end
