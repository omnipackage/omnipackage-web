# frozen_string_literal: true

module RollbarNano
  class Client
    def initialize(url, apikey, logger:, debug: false)
      @apikey = apikey
      @uri = ::URI.parse(url)
      @logger = logger
      @debug = debug
      freeze
    end

    def call(payload)
      http = build_http
      request = build_request(payload)
      respose = http.request(request)
      logger&.debug("#{self.class.name}: #{respose}")
    rescue ::StandardError => e
      logger&.error("#{self.class.name}: #{e.message}")
    end

    private

    attr_reader :uri, :apikey, :logger, :debug

    def build_request(payload)
      headers = {
        'X-Rollbar-Access-Token'  => apikey,
        'Content-Type'            => 'application/json',
        'Accept'                  => 'application/json'
      }
      request = ::Net::HTTP::Post.new(uri, headers)
      request.body = ::JSON.dump(payload)
      request
    end

    def build_http
      http = ::Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 10
      http.ssl_timeout = 10
      http.read_timeout = 30
      http.write_timeout = 30
      http.set_debug_output($stdout) if debug
      http.use_ssl = uri.scheme == 'https'
      http
    end
  end
end
