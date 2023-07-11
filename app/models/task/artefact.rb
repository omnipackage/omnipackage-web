# frozen_string_literal: true

class Task
  class Artefact < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'

    has_one_attached :attachment

    attribute :distro, :string

    validates :distro, presence: true, inclusion: { in: ::Distro.ids }
    validates :attachment, presence: true

    def download(to:)
      ::FileUtils.mkdir_p(to) unless ::File.exist?(to)

      ::File.open(::Pathname.new(to).join(attachment.filename.to_s), 'wb') do |f|
        f.write(attachment.download)
      end
    end
  end
end
