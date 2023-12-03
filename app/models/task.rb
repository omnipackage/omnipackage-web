# frozen_string_literal: true

class Task < ::ApplicationRecord
  belongs_to :sources_tarball, class_name: '::Project::SourcesTarball'
  belongs_to :agent, class_name: '::Agent', optional: true
  has_one :project, class_name: '::Project', through: :sources_tarball
  has_one :user, class_name: '::User', through: :project
  has_many :artefacts, class_name: '::Task::Artefact', dependent: :destroy
  has_many :repositories, ->(task) { where(distro_id: task.distro_ids) }, through: :project, class_name: '::Repository'
  has_one :log, class_name: '::Task::Log', dependent: :destroy

  enum :state, %w[scheduled running finished error].index_with(&:itself), default: 'scheduled'

  broadcast_with ::Broadcasts::Task

  attribute :distro_ids, :string, array: true, default: -> { ::Distro.ids }

  validates :distro_ids, presence: true
  validates_with ::Distro::DistrosValidator

  before_create do
    build_log
  end

  def append_log(text)
    log.append(text)
  end

  def distros
    ::Distro.by_ids(distro_ids)
  end

  def errors?
    artefacts.failed.exists?
  end
end
