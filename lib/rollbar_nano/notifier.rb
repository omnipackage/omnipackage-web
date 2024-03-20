# frozen_string_literal: true

module RollbarNano
  autoload :Client, 'rollbar_nano/client'
  autoload :Config, 'rollbar_nano/config'

  class Notifier
    attr_reader :config

    def initialize(config)
      @config = config
      @apiclient = ::RollbarNano::Client.new(config.endpoint, config.key, logger: config.logger)
      freeze
    end

    def log(level, error, extra: {}, person: {}, request: {}, client: {}) # rubocop: disable Metrics/ParameterLists
      data = build_data(level, error, extra, person, request, client)
      apiclient.call({ data: data })
    end

    private

    attr_reader :apiclient

    def build_data(level, error, extra, person, request, client) # rubocop: disable Metrics/MethodLength, Metrics/AbcSize, Metrics/ParameterLists, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      result = {
        timestamp:    ::Time.now.utc.to_i,
        environment:  config.environment.to_s,
        level:        level.to_s,
        language:     'ruby',
        framework:    config.framework,
        server:       {
          host:       config.host,
          pid:        ::Process.pid,
          root:       config.root.to_s
        },
        notifier: {
          name:       'lib/rollbar_api',
          version:    '0.0.1',
        },
        body:         build_body(error),
      }
      result[:person] = person if person.is_a?(::Hash) && person.any?
      result[:request] = request if request.is_a?(::Hash) && request.any?
      result[:client] = client if client.is_a?(::Hash) && client.any?
      result[:custom] = extra if extra.is_a?(::Hash) && extra.any?
      result
    end

    def build_frames(backtrace)
      backtrace.map do |i|
        filename, lineno, method = i.split(':')
        {
          method:   method.delete('in `').chop,
          lineno:   lineno.to_i,
          filename: filename
        }
      end
    end

    def build_body(error) # rubocop: disable Metrics/MethodLength
      if error.is_a?(::Exception)
        {
          trace: {
            frames: build_frames(error.backtrace),
            exception: {
              message: error.message,
              class: error.class.name
            },
          }
        }
      else
        {
          message: {
            body: error.to_s
          }
        }
      end
    end
  end
end
