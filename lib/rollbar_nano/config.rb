# frozen_string_literal: true

module RollbarNano
  Config = ::Data.define(:key, :endpoint, :logger, :environment, :host, :root, :framework, :code_version) do
    def initialize(**kwargs)
      super(**{
        endpoint:   'https://api.rollbar.com/api/1/item/',
        host:       ::Socket.gethostname
      }.merge(kwargs))
    end
  end
end
