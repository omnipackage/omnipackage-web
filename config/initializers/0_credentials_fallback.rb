require 'active_support/encrypted_configuration'

module CredentialsFallback
  class << self
    def load
      return if credentials_present?

      ::Rails.logger.warn "No encrypted credentials found; falling back to ENV"

      ::Rails.application.credentials = ::ActiveSupport::EncryptedConfiguration.new(
        config_path: nil,            # no encrypted file
        key_path: nil,               # no key file
        env_key: 'DUMMY_KEY',        # dummy key (won’t be used)
        raise_if_missing_key: false, # prevent boot failure
        content: build_content_from_env
      )
    end

    private

    def credentials_present?
      Rails.application.credentials.config.present? rescue false
    end

    def build_content_from_env
      {
        secret_key_base: ENV["SECRET_KEY_BASE"],
        aws: {
          access_key_id: ENV["AWS_ACCESS_KEY_ID"],
          secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
          s3: {
            bucket: ENV["AWS_BUCKET"]
          }
        },
        database: {
          url: ENV["DATABASE_URL"]
        },
        minio: {
          endpoint: ENV["MINIO_ENDPOINT"],
          access_key: ENV["MINIO_ACCESS_KEY_ID"],
          secret_key: ENV["MINIO_SECRET_ACCESS_KEY"],
          repositories_bucket: ENV["REPOSITORIES_BUCKET"],
          repositories_public_url: ENV["REPOSITORIES_PUBLIC_URL"]
        }
      }
    end
  end
end

# Load fallback on boot
CredentialsFallback.load
