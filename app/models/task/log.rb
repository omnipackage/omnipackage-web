# frozen_string_literal: true

class Task
  class Log < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'

    def append(atext)
      return if atext.blank?

      update!(text: text + atext)
      ::Broadcasts::TaskLog.new(self).append(atext)
    end
  end
end
