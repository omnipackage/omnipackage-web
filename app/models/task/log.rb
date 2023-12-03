# frozen_string_literal: true

class Task
  class Log < ::ApplicationRecord
    belongs_to :task, class_name: '::Task', touch: true

    def append(atext)
      return if atext.blank?

      update!(text: text + atext)
    end
  end
end
