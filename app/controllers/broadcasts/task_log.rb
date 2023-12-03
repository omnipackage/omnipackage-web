# frozen_string_literal: true

module Broadcasts
  class TaskLog < ::Broadcasts::BaseBroadcast
    def append(text)
      ::Turbo::StreamsChannel.broadcast_append_later_to(
        model,
        target: "task_log_#{model.id}_text",
        html: text
      )
    end
  end
end
