# frozen_string_literal: true

class Task < ::ApplicationRecord
  belongs_to :sources_tarball, class_name: '::Project::SourcesTarball'
  belongs_to :agent, class_name: '::Agent', optional: true
  has_one :project, class_name: '::Project', through: :sources_tarball
  has_many :artefacts, class_name: '::Task::Artefact', dependent: :destroy

  enum state: %w[scheduled running finished error].index_with(&:itself), _default: 'scheduled'

  attribute :distro_ids, :string, array: true, default: -> { ::Distro.ids }

  validates :distro_ids, presence: true
  validate do
    errors.add(:distro_ids, "must be combination of #{::Distro.ids}") if distro_ids && (distro_ids - ::Distro.ids).any?
  end

  def distros
    ::Distro.by_ids(distro_ids)
  end

  def errors?
    artefacts.failed.exists?
  end
end
