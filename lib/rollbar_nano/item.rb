# frozen_string_literal: true

module RollbarNano
  module Item
    extend self

    def new(config, level, error, extra, person, request, client) # rubocop: disable Metrics/MethodLength, Metrics/AbcSize, Metrics/ParameterLists, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      result = {
        timestamp:    ::Time.now.utc.to_i,
        environment:  config.environment.to_s,
        level:        level.to_s,
        language:     'ruby',
        framework:    config.framework,
        code_version: config.code_version,
        server: {
          host:       config.host,
          pid:        ::Process.pid,
          root:       config.root.to_s
        },
        notifier: {
          name:       'RollbarNano',
          version:    '0.0.1'
        },
        body:         build_body(error),
      }
      result[:person] = person if person.is_a?(::Hash) && person.any?
      result[:request] = request if request.is_a?(::Hash) && request.any?
      result[:client] = client if client.is_a?(::Hash) && client.any?
      result[:custom] = extra if extra.is_a?(::Hash) && extra.any?
      result
    end

    private

    def build_frames(backtrace)
      backtrace.map do |i|
        filename, lineno, method = i.split(':')
        {
          method:   method[4..-2],
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
