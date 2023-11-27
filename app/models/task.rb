# frozen_string_literal: true

class Task < ::ApplicationRecord
  belongs_to :sources_tarball, class_name: '::Project::SourcesTarball'
  belongs_to :agent, class_name: '::Agent', optional: true
  has_one :project, class_name: '::Project', through: :sources_tarball
  has_one :user, class_name: '::User', through: :project
  has_many :artefacts, class_name: '::Task::Artefact', dependent: :destroy
  has_many :repositories, ->(task) { where(distro_id: task.distro_ids) }, through: :project, class_name: '::Repository'

  enum :state, %w[scheduled running finished error].index_with(&:itself), default: 'scheduled'

  after_create_commit do
    broadcast_prepend_later_to [user, :tasks], partial: 'tasks/task', locals: { task: self, highlight: true }
    broadcast_prepend_later_to [project, :tasks], partial: 'tasks/task', locals: { task: self, highlight: true }
  end
  after_update_commit do
    broadcast_replace_later_to [user, :tasks], partial: 'tasks/task', locals: { task: self }
    broadcast_update_later_to self, template: 'tasks/show', assigns: { task: self }
  end
  after_destroy_commit do
    broadcast_remove_to :tasks
  end

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
