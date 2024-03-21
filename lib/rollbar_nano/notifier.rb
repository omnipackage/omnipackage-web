# frozen_string_literal: true

module RollbarNano
  autoload :Client, 'rollbar_nano/client'
  autoload :Config, 'rollbar_nano/config'
  autoload :Item, 'rollbar_nano/item'

  class Notifier
    attr_reader :config

    def initialize(config)
      @config = config
      @queue = ::Queue.new
      run_thread!
      freeze
    end

    def log(level, error, extra: {}, person: {}, request: {}, client: {}) # rubocop: disable Metrics/ParameterLists
      data = ::RollbarNano::Item.new(config, level, error, extra, person, request, client)
      queue.push(data)
    end

    private

    attr_reader :queue

    def run_thread!
      ::Thread.new do
        apiclient = ::RollbarNano::Client.new(config.endpoint, config.key, logger: config.logger)
        loop do
          apiclient.call({ data: queue.pop })
          sleep(1) # sort of rate-limit
        end
      end
    end
  end
end
