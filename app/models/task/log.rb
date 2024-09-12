# frozen_string_literal: true

class Task
  class Log < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'

    before_save :extract_successfull_distro_ids, if: :text_changed?

    def append(atext)
      return if atext.blank?

      self.class.where(id: id).update_all(["text = CONCAT(text, ?)", atext]) # rubocop: disable Rails/SkipsModelValidations
      ::Broadcasts::TaskLog.new(self).append(atext)
      extract_successfull_distro_ids
    end

    private

    def extract_successfull_distro_ids
      self.successfull_distro_ids = text.scan(/successfully finished build for (.+) in/).flatten
    end
  end
end
