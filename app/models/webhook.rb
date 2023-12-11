# frozen_string_literal: true

class Webhook < ::ApplicationRecord
  has_secure_token :key
  encrypts :secret

  belongs_to :project, class_name: '::Project'

  validates :key, presence: true, uniqueness: true

  def sha256(payload_body)
    ::OpenSSL::HMAC.hexdigest(::OpenSSL::Digest.new('sha256'), secret, payload_body.to_s)
  end

  def verify_github(payload_body, payload_signature)
    return true unless secret

    signature = 'sha256=' + sha256(payload_body)
    ::Rack::Utils.secure_compare(signature, payload_signature)
  end

  def sample_header_github(payload_body = nil)
    return unless secret

    ['X-Hub-Signature-256', 'sha256=' + sha256(payload_body)]
  end
end
