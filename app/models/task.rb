# frozen_string_literal: true

class Task < ::ApplicationRecord
  belongs_to :sources_tarball, class_name: '::Project::SourcesTarball'
  belongs_to :agent, class_name: '::Agent', optional: true
  has_one :project, class_name: '::Project', through: :sources_tarball
  has_one :user, class_name: '::User', through: :project
  has_many :artefacts, class_name: '::Task::Artefact', dependent: :destroy
  has_many :repositories, ->(task) { where(distro_id: task.distro_ids) }, through: :project, class_name: '::Repository'
  has_one :log, class_name: '::Task::Log', dependent: :destroy
  has_one :stat, class_name: '::Task::Stat', dependent: :destroy

  enum :state, %w[pending_fetch pending_build running finished cancelled failed].index_with(&:itself), default: 'pending_fetch'

  broadcast_with ::Broadcasts::Task

  attribute :distro_ids, :string, array: true, default: -> { ::Distro.ids }

  scope :by_distro, ->(distro) { where('? = ANY(distro_ids)', distro) }

  validates :distro_ids, presence: true
  validates_with ::Distro::DistrosValidator

  before_create do
    build_log
  end

  class << self
    def start(project, skip_fetch: false, distro_ids: nil)
      task = create(
        sources_tarball:  project.sources_tarball,
        state:            skip_fetch && project.sources_verified? ? 'pending_build' : 'pending_fetch',
        distro_ids:       distro_ids || project.distro_ids.presence || ::Distro.ids
      )
      ::SourcesFetchJob.start(project, task) if task.valid? && !skip_fetch
      task
    end
  end

  def append_log(text)
    touch # rubocop: disable Rails/SkipsModelValidations
    log.append(text)
  end

  def save_stats(stats)
    touch # rubocop: disable Rails/SkipsModelValidations
    stats ||= {}
    stats = ::ActionController::Parameters.new(stats) unless stats.is_a?(::ActionController::Parameters)
    stat = stat || build_stat
    stat.update(stats.except(:task_id).permit!)
  end

  def distros
    ::Distro.by_ids(distro_ids)
  end

  def finish!
    success = unfinished_distros.empty? && artefacts.all?(&:success?)
    update!(state: success ? 'finished' : 'failed', finished_at: ::Time.now.utc)
  end

  def unfinished_distros
    (distro_ids.to_set - artefacts.map(&:distro).to_set).map { |i| ::Distro[i] }
  end

  def duration
    return if !started_at || !finished_at

    ::Duration.build(finished_at - started_at)
  end

  def agent_limits
    return if agent&.user.present? # private agents have no limits

    # if user.root?
    {
      memory: '8g',
      cpus: '6',
      pids: 50_000,
      execute_timeout: 86_400
    }
  end

  def secrets
    project.secrets.to_h
  end
end
