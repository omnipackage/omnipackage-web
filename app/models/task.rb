# frozen_string_literal: true

class Task < ::ApplicationRecord
  belongs_to :sources_tarball, class_name: '::Project::SourcesTarball'
  belongs_to :agent, class_name: '::Agent', optional: true
  has_one :project, class_name: '::Project', through: :sources_tarball

  has_many_attached :artefacts

  enum state: %w[scheduled running finished error].index_with(&:itself), _default: 'scheduled'
end
