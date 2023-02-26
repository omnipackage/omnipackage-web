# frozen_string_literal: true

class Agent
  class Task < ::ApplicationRecord
    belongs_to :task
    belongs_to :agent

    enum state: %w[scheduled busy done].index_with(&:itself), _default: 'scheduled'
  end
end
