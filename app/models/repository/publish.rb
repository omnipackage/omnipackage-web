# frozen_string_literal: true

class Repository
  class Publish
    attr_reader :repository

    def initialize(repository)
      @repository = repository
      @logger = ::ActiveSupport::TaggedLogging.new(::Rails.logger)
    end

    def call(artefacts) # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
      logger.tagged('publish', "repo=#{repository.id}", "project=#{repository.project.id}", "distro=#{repository.distro.id}") do
        logger.info('start')

        repository.publishing!
        storage.create_bucket_if_not_exists!

        ::Dir.mktmpdir do |dir|
          sync_repo_files(artefacts, dir)
          logger.info("finish\n#{::ShellUtil.execute("tree #{dir}").out}")
        end
        repository.update!(published_at: ::Time.now.utc, last_publish_error: nil, publish_status: 'published')
      rescue ::StandardError => e
        logger.info("error: #{e.message}")
        repository.update!(last_publish_error: e.message, publish_status: 'pending')
        raise
      end
    end

    private

    attr_reader :logger

    delegate :storage, to: :repository

    def sync_repo_files(artefacts, dir)
      suitable_artefacts = artefacts.select { |i| i.filetype == repository.distro.package_type }
      return if suitable_artefacts.empty?

      storage.download_all(to: dir)
      suitable_artefacts.each { |i| i.download(to: dir, overwrite_existing: true) }

      build_repo_manage(dir).sync

      storage.upload_all(from: dir)
      storage.delete_deleted_files(from: dir)
    end

    def build_repo_manage(dir)
      ::RepoManage::Repo.new(
        runtime:      build_runtime(dir),
        type:         repository.distro.package_type,
        gpg_key:      repository.gpg_key,
        project_slug: repository.project.slug,
        distro_name:  repository.distro.name,
        distro_url:   storage.url
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
