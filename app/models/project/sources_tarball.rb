# frozen_string_literal: true

class Project
  class SourcesTarball < ::ApplicationRecord
    belongs_to :project, class_name: '::Project'
    has_many :tasks, class_name: '::Task', dependent: :destroy

    # after_update_commit -> { project.broadcast_replace_to(project, partial: 'projects/project', locals: { project: project }) }

    def decrypted_tarball
      ::ShellUtil.decrypt(tarball, passphrase: ::Rails.application.credentials.sources_tarball_passphrase)
    end

    def decrypted_tarball_filename
      "#{project.name}-sources-#{updated_at.strftime('%Y%m%d-%H%M%S')}.tar.xz".freeze
    end

    def distros
      return unless config

      ::Distro.by_ids(config['builds'].pluck('distro').uniq)
    end

    def installable_package_name(for_distro)
      config['builds'].find { |i| i['distro'] == for_distro }&.dig('installable_package_name')
    end
  end
end
