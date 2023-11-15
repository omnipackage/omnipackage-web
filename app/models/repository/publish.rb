# frozen_string_literal: true

class Repository
  class Publish
    attr_reader :repository

    def initialize(repository)
      @repository = repository
    end

    def call(artefacts)
      log_start

      repository.create_bucket_if_not_exists!

      ::Dir.mktmpdir do |dir|
        sync_repo_files(artefacts, dir)
        log_finish(dir)
      end
    rescue ::StandardError => e
      log_error(e)
    end

    private

    def log_start
      ::Rails.logger.info("Publishing #{repository.project.name} for #{repository.distro.name} (repository ##{repository.id})")
    end

    def log_finish(dir)
      ::Rails.logger.info("Done publishing for #{repository.distro.name} (##{repository.id})\n" + ::ShellUtil.execute("tree #{dir}").out)
    end

    def log_error(exception)
      ::Rails.logger.error("Repository for #{repository.distro.name} (##{repository.id}) publish error: #{exception.message}")
    end

    def sync_repo_files(artefacts, dir)
      repository.download_all(to: dir)

      artefacts.select { |i| i.filetype == repository.distro.package_type }.each { |i| i.download(to: dir, overwrite_existing: true) }

      build_repo_manage(dir).sync

      repository.upload_all(from: dir)
    end

    def build_repo_manage(dir)
      ::RepoManage::Repo.new(
        runtime:            build_runtime(dir),
        type:               repository.distro.package_type,
        gpg_key:            repository.gpg_key,
        project_safe_name:  repository.project.safe_name,
        distro_name:        repository.distro.name,
        distro_url:         repository.url
      )
    end

    def build_runtime(workdir)
      ::RepoManage::Runtime.new(
        executable: ::APP_SETTINGS.fetch(:container_runtime),
        workdir:    workdir,
        image:      repository.distro.image,
        setup_cli:  repository.distro.setup_repo
      )
    end
  end
end
