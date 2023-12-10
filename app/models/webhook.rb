# frozen_string_literal: true

class Webhook < ::ApplicationRecord
  has_secure_token :key
  encrypts :secret

  belongs_to :project, class_name: '::Project'

  validates :key, presence: true, uniqueness: true

  def verify_github(payload_body, payload_signature)
    return true unless secret

    signature = 'sha256=' + ::OpenSSL::HMAC.hexdigest(::OpenSSL::Digest.new('sha256'), secret, payload_body)
    ::Rack::Utils.secure_compare(signature, payload_signature)
  end
end
