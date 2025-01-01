class RepositoryPublishJob < ::ApplicationJob
  queue_as :publish

  class << self
    def start(task)
      return if task.cancelled?

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
    afacts = ::Task::Artefact.where(id: artefacts_ids)
    return unless afacts.exists?

    ::Repository::Publish.new(repo).call(afacts)
  end
end
