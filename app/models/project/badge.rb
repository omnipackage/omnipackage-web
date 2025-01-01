class Project
  class Badge
    delegate :url, to: :storage_config
    delegate :generate, to: :builder

    def initialize(project)
      @project = project
      @filename = "#{project.slug}.svg"
      @storage_config = project.repository_storage_config.append_path(filename)
      @builder = ::SvgBadgeBuilder.new(title:, text: build_text(project))
    end

    def generate_and_upload
      ::Dir.mktmpdir do |dir|
        builder.save(dir:, filename:)
        upload(::Pathname.new(dir).join(filename))
      end
    end

    def markdown(linkto)
      <<~MARKDOWN.strip
      [![#{title}](#{url})](#{linkto})
      MARKDOWN
    end

    private

    attr_reader :storage_config, :filename, :builder

    def upload(filepath)
      ::StorageClient.new(storage_config.client_config).upload(
        bucket: storage_config.bucket,
        from: filepath,
        key: storage_config.path,
        content_type: 'image/svg+xml'
      )
    end

    def build_text(project)
      distros = ->(pkg) { ::Distro.by_package_type(pkg).map { "'#{_1.id}'" }.join(',') }
      sql = <<~SQL.squish
      COUNT(CASE WHEN distro_id IN (#{distros['rpm']}) THEN 1 ELSE NULL END) AS rpm,
      COUNT(CASE WHEN distro_id IN (#{distros['deb']}) THEN 1 ELSE NULL END) AS deb
      SQL
      result = project.repositories.published.select(sql).to_a.sole

      "#{result.rpm} RPM #{result.deb} DEB"
    end

    def title
      'OmniPackage repositories badge'
    end
  end
end
