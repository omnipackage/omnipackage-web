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

    def run_thread! # rubocop: disable Metrics/MethodLength
      ::Thread.new do
        apiclient = ::RollbarNano::Client.new(config.endpoint, config.key, logger: config.logger)
        loop do
          data = queue.pop
          break if data == 'quit!'

          apiclient.call({ data: data })
          sleep(1) # sort of rate-limit
        end
      end

      at_exit do
        queue.push('quit!')
      end
    end
  end
end
