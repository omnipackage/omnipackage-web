# frozen_string_literal: true

class Task
  class Log < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'

    before_save :set_successfull_distro_ids, if: :text_changed?

    # rubocop: disable Rails/SkipsModelValidations, Layout/FirstArrayElementIndentation
    def append(atext)
      return if atext.blank?

      self.class.where(id: id).update_all([
        "text = CONCAT(text, ?), successfull_distro_ids = ARRAY_CAT(successfull_distro_ids, ARRAY[?])",
        atext,
        extract_successfull_distro_ids(atext)
      ])
      ::Broadcasts::TaskLog.new(self).append(atext)
    end
    # rubocop: enable Rails/SkipsModelValidations, Layout/FirstArrayElementIndentation

    private

    def set_successfull_distro_ids
      self.successfull_distro_ids = extract_successfull_distro_ids(text)
    end

    def extract_successfull_distro_ids(string)
      string.scan(/successfully finished build for (.+) in/).flatten
    end
  end
end
