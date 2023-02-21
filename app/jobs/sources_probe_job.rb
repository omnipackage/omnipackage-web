# frozen_string_literal: true

class SourcesProbeJob < ::ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(kind:, location:)
    ::Sources.new(kind: kind, location: location)
  end
end
