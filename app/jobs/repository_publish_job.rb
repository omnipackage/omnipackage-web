# frozen_string_literal: true

class RepositoryPublishJob < ::ApplicationJob
  queue_as :long

  class << self
    def start(task)
      return unless task.finished?

      task.repositories.update(publish_status: 'pending')
      perform_later(task.id)
    end
  end

  def perform(task_id)
    task = ::Task.find(task_id)

    task.artefacts.group_by(&:distro).each do |distro, afacts|
      task.repositories.where(distro_id: distro).find_each do |repo|
        ::Repository::Publish.new(repo).call(afacts)
      end
    end
  end
end
