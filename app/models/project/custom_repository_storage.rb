# frozen_string_literal: true

class Project
  class CustomRepositoryStorage < ::ApplicationRecord
    belongs_to :project, class_name: '::Project', inverse_of: :custom_respository_storage

    validates :bucket, presence: true, format: /\A(?!(^xn--|.+-s3alias$))^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]\z/, uniqueness: { scope: :endpoint }
    validates :path, uniqueness: { scope: [:endpoint, :bucket] }
    validates :region, :endpoint, :access_key_id, :secret_access_key, presence: true

    encrypts :secret_access_key

    def repository_storage_config
      ::Repository::Storage::Config.new(
        client_config: ::StorageClient::Config.new(endpoint:, region:, access_key_id:, secret_access_key:),
        bucket:,
        path:
      )
    end
  end
end
