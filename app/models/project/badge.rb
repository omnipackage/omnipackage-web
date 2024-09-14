# frozen_string_literal: true

class Project
  class Badge
    attr_reader :project

    delegate :url, to: :storage_config

    def initialize(project)
      @project = project
      @filename = "#{project.slug}.svg"
      @storage_config = project.repository_storage_config.append_path(filename)
    end

    def generate_and_upload
      ::Dir.mktmpdir do |dir|
        ::SvgBadgeBuilder.new(title:, text:).save(dir:, filename:)
        upload(::Pathname.new(dir).join(filename))
      end
    end

    def markdown(linkto)
      <<~MARKDOWN.strip
      [![#{title}](#{url})](#{linkto})
      MARKDOWN
    end

    private

    attr_reader :storage_config, :filename

    def upload(filepath)
      ::StorageClient.new(storage_config.client_config).upload(
        bucket: storage_config.bucket,
        from: filepath,
        key: storage_config.path,
        content_type: 'image/svg+xml'
      )
    end

    def text
      "#{project.repositories.published.rpm.count} RPM #{project.repositories.published.deb.count} DEB"
    end

    def title
      'OmniPackage repositories badge'
    end
  end
end
