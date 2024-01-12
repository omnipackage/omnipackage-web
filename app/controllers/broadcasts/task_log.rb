# frozen_string_literal: true

module Broadcasts
  class TaskLog < ::Broadcasts::BaseBroadcast
    def append(text)
      ::Turbo::StreamsChannel.broadcast_append_later_to(
        [model, :text],
        target: dom_id(model, :text),
        html: text
      )
    end
  end
end
