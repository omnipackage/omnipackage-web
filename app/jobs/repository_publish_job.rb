# frozen_string_literal: true

class RepositoryPublishJob < ::ApplicationJob
  queue_as :default

  def perform(task_id) # rubocop: disable Metrics/MethodLength
    task = ::Task.find(task_id)
    return unless task.finished?

    task.artefacts.group_by(&:distro).each do |distro, afacts|
      repo = task.project.repositories.find_by(distro_id: distro)
      repo&.create_bucket_if_not_exists!
      ::Dir.mktmpdir do |dir|
        repo&.download_all(to: dir)
        create_or_update_repo_files(::Distro[distro], afacts, dir)
        repo&.upload_all(from: dir)
      end
    end
  end

  private

  def create_or_update_repo_files(distro, artefacts, dir)
    artefacts.select { |i| i.filetype == distro.package_type }.each { |i| i.download(to: dir, overwrite_existing: true) }

    rt = ::RepoManage::Runtime.new(executable: 'podman', workdir: dir, image: distro.image, setup_cli: distro.setup_repo)
    ::RepoManage::Repo.new(runtime: rt, directory: dir, type: distro.package_type).refresh

    puts "*****" # rubocop: disable Rails/Output
    puts ::ShellUtil.execute("tree #{dir}").out # rubocop: disable Rails/Output
    puts "*****" # rubocop: disable Rails/Output
  end
end
