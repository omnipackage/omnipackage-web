# frozen_string_literal: true

module Broadcasts
  class Task < ::Broadcasts::BaseBroadcast
    def create # rubocop: disable Metrics/MethodLength
      ::Turbo::StreamsChannel.broadcast_prepend_later_to(
        [model.user, :tasks],
        target: dom_id(model),
        partial: 'tasks/task',
        locals: { task: model, highlight: true }
      )

      ::Turbo::StreamsChannel.broadcast_prepend_later_to(
        [model.project, :tasks],
        target: dom_id(model),
        partial: 'tasks/task',
        locals: { task: model, highlight: true }
      )
    end

    def update # rubocop: disable Metrics/MethodLength
      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        [model.user, :tasks],
        target: dom_id(model),
        partial: 'tasks/task',
        locals: { task: model }
      )

      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        [model.project, :tasks],
        target: dom_id(model),
        partial: 'tasks/task',
        locals: { task: model }
      )

      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        model,
        target: dom_id(model),
        template: 'tasks/show',
        assigns: { task: model },
        layout: false
      )
    end

    def destroy
      ::Turbo::StreamsChannel.broadcast_remove_to(:tasks, target: dom_id(model))
    end
  end
end
