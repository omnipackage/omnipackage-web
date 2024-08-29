# frozen_string_literal: true

class Project
  class RepositoryStorage < ::ApplicationRecord
    validates :bucket, presence: true, format: /\A(?!(^xn--|.+-s3alias$))^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]\z/
    validates :region, :endpoint, :access_key_id, :secret_access_key, presence: true
  end
end
