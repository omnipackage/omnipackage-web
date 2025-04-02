class Project
  class SourcesTarball < ::ApplicationRecord
    belongs_to :project, class_name: '::Project'
    has_many :tasks, class_name: '::Task', dependent: :destroy

    has_one_attached :tarball

    def upload_tarball(io)
      self.tarball = ::ActiveStorage::Blob.create_and_upload!(
        io:           io,
        filename:     "#{project.slug}-sources-#{::Time.now.utc.strftime('%Y%m%d-%H%M%S')}.tar.xz"
      )
      self
    end

    def distros
      return unless config

      ::Distro.by_ids(config['builds'].pluck('distro').uniq)
    end

    def distro_ids
      distros&.map(&:id)
    end

    def package_name(for_distro)
      config['builds'].find { |i| i['distro'] == for_distro }&.dig('package_name')
    end
  end
end
