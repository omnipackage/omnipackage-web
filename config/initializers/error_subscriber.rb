# frozen_string_literal: true

class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    ::Rails.logger.error("<ErrorSubscriber> #{error}, handled: #{handled}, severity: #{severity}, context: #{context}, source: #{source}")
  end
end

::Rails.error.subscribe(ErrorSubscriber.new)
