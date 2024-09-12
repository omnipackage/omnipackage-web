# frozen_string_literal: true

class Task
  class Log < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'

    before_save :set_successfull_distro_ids, if: :text_changed?

    def append(atext) # rubocop: disable Metrics/MethodLength
      return if atext.blank?

      distros = extract_successfull_distro_ids(atext)
      query_arr = if distros.any?
                    [
                      "text = CONCAT(text, ?), successfull_distro_ids = ARRAY_CAT(successfull_distro_ids, ARRAY[?])",
                      atext,
                      distros
                    ]
                  else
                    ["text = CONCAT(text, ?)", atext]
                  end
      self.class.where(id: id).update_all(query_arr) # rubocop: disable Rails/SkipsModelValidations
      ::Broadcasts::TaskLog.new(self).append(atext)
    end

    private

    def set_successfull_distro_ids
      self.successfull_distro_ids = extract_successfull_distro_ids(text)
    end

    def extract_successfull_distro_ids(string)
      string.scan(/successfully finished build for (.+) in/).flatten.compact
    end
  end
end
