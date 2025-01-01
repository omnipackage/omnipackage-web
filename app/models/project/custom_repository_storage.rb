class Project
  class CustomRepositoryStorage < ::ApplicationRecord
    belongs_to :project, class_name: '::Project', inverse_of: :custom_repository_storage

    validates :bucket, presence: true, format: /\A(?!(^xn--|.+-s3alias$))^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]\z/, uniqueness: { scope: :endpoint }
    validates :path, uniqueness: { scope: [:endpoint, :bucket] }
    validates :endpoint, :access_key_id, :secret_access_key, presence: true
    validate :reachable

    encrypts :secret_access_key

    def repository_storage_config
      ::Repository::Storage::Config.new(
        client_config: ::StorageClient::Config.new(endpoint:, region:, access_key_id:, secret_access_key:),
        bucket:,
        path:,
        bucket_public_url:
      )
    end

    private

    def reachable
      storage = ::Repository::Storage.new(repository_storage_config)
      storage.ping!
      unless storage.bucket_exists?
        errors.add(:bucket, 'does not exist')
      end
    rescue ::StandardError => e
      errors.add(:endpoint, e.message)
    end
  end
end
