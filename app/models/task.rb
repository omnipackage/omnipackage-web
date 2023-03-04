# frozen_string_literal: true

class Task < ::ApplicationRecord
  belongs_to :sources_tarball, class_name: '::Project::SourcesTarball'
  has_many :agent_tasks, class_name: '::Agent::Task', dependent: :destroy
  has_one :project, class_name: '::Project', through: :sources_tarball

  enum state: %w[fresh running finished error].index_with(&:itself), _default: 'fresh'
end
