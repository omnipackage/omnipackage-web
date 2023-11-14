# frozen_string_literal: true

class RepositoryPublishJob < ::ApplicationJob
  queue_as :default

  def perform(task_id)
    task = ::Task.find(task_id)
    return unless task.finished?

    task.artefacts.group_by(&:distro).each do |distro, afacts|
      task.project.repositories.where(distro_id: distro).find_each do |repo|
        # next unless repo.distro_id == 'ubuntu_22.04'
        publish(repo, afacts)
      end
    end
    nil
  end

  private

  def publish(repo, afacts) # rubocop: disable Metrics/AbcSize
    ::Rails.logger.info("Publishing to #{repo.id} for #{repo.distro.name}")
    repo.create_bucket_if_not_exists!
    ::Dir.mktmpdir do |dir|
      repo.download_all(to: dir)
      create_or_update_repo_files(repo, afacts, dir)
      repo.upload_all(from: dir)

      ::Rails.logger.info(::ShellUtil.execute("tree #{dir}").out)
    end
  rescue ::StandardError => e
    ::Rails.logger.error("Repo #{repo.id} publish error: #{e.message}")
  end

  def create_or_update_repo_files(repo, artefacts, dir) # rubocop: disable Metrics/AbcSize
    artefacts.select { |i| i.filetype == repo.distro.package_type }.each { |i| i.download(to: dir, overwrite_existing: true) }

    rt = ::RepoManage::Runtime.new(executable: 'podman', workdir: dir, image: repo.distro.image, setup_cli: repo.distro.setup_repo)
    reposrv = ::RepoManage::Repo.new(runtime: rt, type: repo.distro.package_type, gpg_key: repo.gpg_key)
    reposrv.call
    reposrv.write_rpm_repo_file(repo.project.safe_name, repo.distro.name, repo.url)
  end
end
