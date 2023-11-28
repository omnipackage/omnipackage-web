# frozen_string_literal: true

class RepositoryPublishJob < ::ApplicationJob
  queue_as :long

  class << self
    def start(task)
      return unless task.finished?

      task.repositories.update(publish_status: 'pending')
      jobs = []
      task.artefacts.group_by(&:distro).each do |distro, afacts|
        task.repositories.where(distro_id: distro).ids.each do |repo_id|
          jobs << new(repo_id, afacts.map(&:id))
        end
      end
      ::ActiveJob.perform_all_later(jobs)
    end
  end

  def perform(repository_id, artefacts_ids)
    repo = ::Repository.find(repository_id)
    afacts = ::Task::Artefact.find(artefacts_ids)

    ::Repository::Publish.new(repo).call(afacts)
  end
end
