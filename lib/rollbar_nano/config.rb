# frozen_string_literal: true

module RollbarNano
  Config = ::Data.define(:key, :endpoint, :logger, :environment, :host, :root, :framework)
end
