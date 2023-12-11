# frozen_string_literal: true

class Webhook < ::ApplicationRecord
  has_secure_token :key
  encrypts :secret

  belongs_to :project, class_name: '::Project'

  validates :key, presence: true, uniqueness: true

  before_validation do
    self.secret = nil if secret.blank?
  end

  def verify(request)
    return true unless secret

    ::Rack::Utils.secure_compare('sha256=' + sha256_hmac(request.raw_post), request.headers['X-Hub-Signature-256'].to_s)
  end

  def sha256_hmac(payload_body)
    ::OpenSSL::HMAC.hexdigest(::OpenSSL::Digest.new('sha256'), secret.to_s, payload_body.to_s)
  end

  def sample_header_github(payload_body = nil)
    return unless secret

    'X-Hub-Signature-256: sha256=' + sha256_hmac(payload_body)
  end
end
