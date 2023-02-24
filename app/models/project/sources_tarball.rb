# frozen_string_literal: true

class Project
  class SourcesTarball < ::ApplicationRecord
    belongs_to :project

    def decrypted_tarball
      ::ShellUtil.decrypt(tarball, passphrase: ::Rails.application.credentials.sources_tarball_passphrase)
    end
  end
end
