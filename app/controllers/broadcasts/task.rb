# frozen_string_literal: true

module Broadcasts
  class Task < ::Broadcasts::BaseBroadcast
    def create # rubocop: disable Metrics/MethodLength
      ::Turbo::StreamsChannel.broadcast_prepend_later_to(
        [model.user, :tasks],
        target: 'tasks',
        partial: 'tasks/task',
        locals: { task: model, highlight: true }
      )

      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        [model.project, :task_state],
        target: dom_id(model.project, :task_state),
        partial: 'projects/task_state',
        locals: { project: model.project }
      )
    end

    def update # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        [model.user, :tasks],
        target: dom_id(model),
        partial: 'tasks/task',
        locals: { task: model }
      )

      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        [model, :show],
        target: dom_id(model, :show),
        template: 'tasks/show',
        assigns: { task: model },
        layout: false
      )

      ::Turbo::StreamsChannel.broadcast_update_later_to(
        [model, :state_icon],
        target: dom_id(model, :state_icon),
        partial: 'tasks/state_icon',
        locals: { task: model }
      )

      ::Turbo::StreamsChannel.broadcast_replace_later_to(
        [model.project, :task_state],
        target: dom_id(model.project, :task_state),
        partial: 'projects/task_state',
        locals: { project: model.project }
      )
    end

    def destroy
      ::Turbo::StreamsChannel.broadcast_remove_to(:tasks, target: dom_id(model))
    end
  end
end
