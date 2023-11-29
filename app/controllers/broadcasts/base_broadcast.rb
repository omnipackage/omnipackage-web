# frozen_string_literal: true

module Broadcasts
  class BaseBroadcast
    class << self
      def attach!(ar_model_class)
        ar_model_class.instance_exec(self) do |this|
          after_create_commit { this.new(self).create }
          after_update_commit { this.new(self).update }
          after_destroy_commit { this.new(self).destroy }
        end
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
