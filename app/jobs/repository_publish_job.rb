# frozen_string_literal: true

class RepositoryPublishJob < ::ApplicationJob
  queue_as :default

  def perform(task_id)
    task = ::Task.find(task_id)
    return unless task.finished?

    task.artefacts.group_by(&:distro).each do |distro, afacts|
      task.project.repositories.where(distro_id: distro).find_each do |repo|
        ::Repository::Publish.new(repo).call(afacts)
      end
    end
  end
end
