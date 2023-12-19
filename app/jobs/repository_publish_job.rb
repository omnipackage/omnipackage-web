# frozen_string_literal: true

class RepositoryPublishJob < ::ApplicationJob
  queue_as :long
  retry_on ::StandardError, wait: 10.seconds, attempts: 3

  class << self
    def start(task)
      jobs = []
      task.artefacts.successful.group_by(&:distro).each do |distro, afacts|
        task.repositories.where(distro_id: distro).find_each do |repo|
          repo.pending!
          jobs << new(repo.id, afacts.map(&:id))
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
