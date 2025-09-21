class Turnstile
  class << self
    def secret_key
      ::ENV['CLOUDFLARE_TURNSTILE_SECRET_KEY']
    end

    def site_key
      ::ENV['CLOUDFLARE_TURNSTILE_SITE_KEY']
    end

    def enabled?
      secret_key.present? && site_key.present?
    end

    def verification_url
      ::URI.parse('https://challenges.cloudflare.com/turnstile/v0/siteverify')
    end
  end

  def initialize(logger: ::Rails.logger)
    @logger = logger
  end

  def call(response, remoteip)
    return true unless self.class.enabled?
    return false unless response

    response = ::Net::HTTP.post_form(self.class.verification_url, secret: self.class.secret_key, response:, remoteip:)
    logger.info("Turnstile response: #{response.body}")
    !!::JSON.parse(response.body).dig('success')
  end

  private

  attr_reader :logger
end
