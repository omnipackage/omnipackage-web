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

        installable_filename = nil
        ::Dir.mktmpdir do |dir|
          synced_artefacts = sync_repo_files(artefacts, dir)
          installable_filename = extract_installable_filename(dir, synced_artefacts)
          logger.info("finish\n#{::ShellUtil.execute("tree #{dir}").out}")
        end
        repository.update!(published_at: ::Time.now.utc, last_publish_error: nil, publish_status: 'published', installable_filename:)
        repository.project.badge.generate_and_upload
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

      # storage.download_all(to: dir)
      suitable_artefacts.each { |i| i.download(to: dir, overwrite_existing: true) }

      build_repo_manage(dir).sync

      storage.upload_all(from: dir)
      storage.delete_deleted_files(from: dir)

      suitable_artefacts
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

    def extract_installable_filename(dir, synced_artefacts)
      return unless synced_artefacts

      installable_filename = synced_artefacts.map(&:filename).find { _1.include?(repository.package_name) }
      result = ::Dir.glob(dir + '/**/*').find { ::File.basename(_1) == installable_filename }
      result.gsub(dir, '')
    end
  end
end
