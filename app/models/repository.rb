# frozen_string_literal: true

class Repository < ::ApplicationRecord
  belongs_to :project

  validates :distro_id, inclusion: { in: ::Distro.ids }

  def distro
    ::Distro[distro_id]
  end

  def storage_client
    if access_key_id && secret_access_key
      ::StorageClient.new(endpoint: endpoint, access_key_id: access_key_id, secret_access_key: secret_access_key, region: region)
    else
      ::StorageClient.build_default
    end
  end
end