# frozen_string_literal: true

class Task
  class Log < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'

    def append(atext)
      return if atext.blank?

      self.class.where(id: id).update_all(["text = CONCAT(text, ?)", atext]) # rubocop: disable Rails/SkipsModelValidations
      ::Broadcasts::TaskLog.new(self).append(atext)
    end

    def successfull_distro_ids
      text.scan(/successfully finished build for (.+) in/).flatten
    end
  end
end
