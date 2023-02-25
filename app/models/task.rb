# frozen_string_literal: true

class Task < ::ApplicationRecord
  belongs_to :sources_tarball, class_name: '::Project::SourcesTarball'

  enum state: %w[fresh running finished error].index_with(&:itself), _default: 'fresh'

  delegate :project, to: :sources_tarball
end
