class Task
  class Artefact < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'

    has_one_attached :attachment

    scope :failed, -> { where(error: true) }
    scope :successful, -> { where.not(error: true) }

    validates :distro, presence: true, inclusion: { in: ::Distro.ids }
    validates :attachment, presence: true

    def filename
      attachment.filename.to_s
    end

    def filetype
      attachment.filename.extension
    end

    def distro_object
      ::Distro[distro]
    end

    def success?
      !error
    end

    def download(to:, overwrite_existing: false) # rubocop: disable Metrics/MethodLength
      ::FileUtils.mkdir_p(to) unless ::File.exist?(to)

      fpath = ::Pathname.new(to).join(filename)
      if ::File.exist?(fpath)
        if overwrite_existing
          ::File.delete(fpath)
        else
          raise "file #{fpath} already exists"
        end
      end

      ::File.open(fpath, 'wb') do |f|
        f.write(attachment.download)
      end
    end
  end
end
