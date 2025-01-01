module Broadcasts
  class BaseBroadcast
    module AR
      def broadcast_with(klass)
        # TODO with new turbo-rails version add `unless suppressed_turbo_broadcasts?`
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
