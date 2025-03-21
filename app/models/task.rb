class Task < ::ApplicationRecord
  belongs_to :project, class_name: '::Project'
  belongs_to :agent, class_name: '::Agent', optional: true
  has_one :user, class_name: '::User', through: :project
  has_many :artefacts, class_name: '::Task::Artefact', dependent: :destroy
  has_many :repositories, ->(task) { where(distro_id: task.distro_ids) }, through: :project, class_name: '::Repository'
  has_one :log, class_name: '::Task::Log', dependent: :destroy
  has_one :stat, class_name: '::Task::Stat', dependent: :destroy

  has_one_attached :sources

  enum :state, %w[pending_fetch pending_build running finished cancelled failed].index_with(&:itself), default: 'pending_fetch'

  broadcast_with ::Broadcasts::Task

  attribute :distro_ids, :string, array: true, default: -> { ::Distro.ids }

  scope :by_distro, ->(distro) { where('? = ANY(distro_ids)', distro) }

  validates :distro_ids, presence: true
  validates_with ::Distro::DistrosValidator
  validates :sources, presence: true, unless: -> { pending_fetch? }

  before_create { build_log }

  Progress = ::Data.define(:done, :failed, :total) do
    def to_s = "#{done.size + failed.size}/#{total.size}"
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
      memory: '16g',
      cpus: '6',
      pids: 50_000,
      execute_timeout: 86_400
    }
  end

  def secrets
    project.secrets.to_h
  end

  def progress
    d = log.distro_ids
    Progress.new(done: d.successfull.sort, failed: d.failed.sort, total: distro_ids.sort)
  end

  def copy_project_sources!
    sources.attach(project.sources_tarball.tarball.blob) if project.sources_verified?
  end

  def reset_progress!
    transaction do
      log&.update!(text: '')
      update!(state: 'pending_build', agent_id: nil)
    end
  end
end
