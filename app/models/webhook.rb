class Webhook < ::ApplicationRecord
  has_secure_token :key
  encrypts :secret

  belongs_to :project, class_name: '::Project'

  validates :key, presence: true, uniqueness: true
  validates :debounce, presence: true

  attribute :debounce, default: -> { 10.seconds }

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

  def can_trigger_now?
    !last_trigger_at || (last_trigger_at + debounce) < ::Time.now.utc
  end

  def trigger_async!
    return unless can_trigger_now?

    ::AsyncTaskStarterJob.set(wait: 5.seconds).perform_later(project_id)
    update(last_trigger_at: ::Time.now.utc)
  end
end
