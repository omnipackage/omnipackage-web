# frozen_string_literal: true

class Project
  class SourcesTarball < ::ApplicationRecord
    belongs_to :project

    def decrypted_tarball
      ::ShellUtil.decrypt(tarball, passphrase: ::Rails.application.credentials.sources_tarball_passphrase)
    end

    def decrypted_tarball_filename
      "#{project.name}-sources-#{updated_at.strftime('%Y%m%d-%H%M%S')}.tar.xz".freeze
    end
  end
end
