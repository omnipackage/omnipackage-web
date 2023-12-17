# frozen_string_literal: true

class Task < ::ApplicationRecord
  belongs_to :sources_tarball, class_name: '::Project::SourcesTarball'
  belongs_to :agent, class_name: '::Agent', optional: true
  has_one :project, class_name: '::Project', through: :sources_tarball
  has_one :user, class_name: '::User', through: :project
  has_many :artefacts, class_name: '::Task::Artefact', dependent: :destroy
  has_many :repositories, ->(task) { where(distro_id: task.distro_ids) }, through: :project, class_name: '::Repository'
  has_one :log, class_name: '::Task::Log', dependent: :destroy

  enum :state, %w[pending_fetch pending_build running finished cancelled].index_with(&:itself), default: 'pending_fetch'

  broadcast_with ::Broadcasts::Task

  attribute :distro_ids, :string, array: true, default: -> { ::Distro.ids }

  scope :by_distro, ->(distro) { where('? = ANY(distro_ids)', distro) }

  validates :distro_ids, presence: true
  validates_with ::Distro::DistrosValidator

  before_create do
    build_log
  end

  class << self
    def start(project, skip_fetch: false, distro_ids: ::Distro.ids)
      task = create!(
        sources_tarball:  project.sources_tarball,
        state:            skip_fetch ? 'pending_build' : 'pending_fetch',
        distro_ids:       distro_ids
      )
      ::SourcesFetchJob.start(project, task) unless skip_fetch
      task
    end
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

  def finish!
    update!(state: 'finished', finished_at: ::Time.now.utc)
  end

  def duration
    return if !started_at || !finished_at

    ::Duration.build(finished_at - started_at)
  end
end
