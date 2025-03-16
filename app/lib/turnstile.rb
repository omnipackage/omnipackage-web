class Turnstile
  class << self
    def secret_key
      ::Rails.application.credentials.dig(:cloudflare_turnstile, :secret_key)
    end

    def site_key
      ::Rails.application.credentials.dig(:cloudflare_turnstile, :site_key)
    end

    def enabled?
      secret_key.present? && site_key.present?
    end

    def verification_url
      'https://challenges.cloudflare.com/turnstile/v0/siteverify'
    end
  end

  def initialize(logger: ::Rails.logger)
    @logger = logger
  end

  def call(response, remoteip)
    return true unless self.class.enabled?
    return false unless response

    response = ::Net::HTTP.post_form(::URI.parse(self.class.verification_url), secret: self.class.secret_key, response:, remoteip:)
    logger.info("Turnstile response: #{response.body}")
    !!::JSON.parse(response.body).dig('success')
  end

  private

  attr_reader :logger
end
