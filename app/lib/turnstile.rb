class Turnstile
  class << self
    def secret_key
      ::Rails.application.credentials.dig(:cloudflare_turnstile, :secret_key)
    end

    def site_key
      ::Rails.application.credentials.dig(:cloudflare_turnstile, :site_key)
    end

    def verification_url
      'https://challenges.cloudflare.com/turnstile/v0/siteverify'
    end
  end

  def verify(controller_context)
    call(controller_context.params['cf-turnstile-response'], controller_context.request.remote_ip)
  end

  def call(response, remoteip)
    return false unless response

    response = ::Net::HTTP.post_form(::URI.parse(self.class.verification_url), secret: self.class.secret_key, response:, remoteip:)
    !!::JSON.parse(response.body).dig('success')
  end
end
