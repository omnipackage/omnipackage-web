# frozen_string_literal: true

module Broadcasts
  class BaseBroadcast
    module AR
      def broadcast_with(klass)
        raise ::ArgumentError, "wrong broadcaster class #{klass}" unless klass < ::Broadcasts::BaseBroadcast

        after_create_commit { klass.new(self).create }
        after_update_commit { klass.new(self).update }
        after_destroy_commit { klass.new(self).destroy }
      end
    end

    include ::ActionView::RecordIdentifier

    attr_reader :model

    def initialize(model)
      @model = model
    end

    def create
    end

    def update
    end

    def destroy
    end
  end
end
