# frozen_string_literal: true

class Agent
  class Task < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'
    belongs_to :agent, class_name: '::Agent'
    has_one :project, class_name: '::Project', through: :task
    has_one :sources_tarball, class_name: '::Project::SourcesTarball', through: :task

    enum state: %w[scheduled busy done].index_with(&:itself), _default: 'scheduled'
  end
end
