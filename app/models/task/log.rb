# frozen_string_literal: true

class Task
  class Log < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'

    before_save :set_progress_distro_ids, if: :text_changed?

    def append(atext) # rubocop: disable Metrics/MethodLength
      return if atext.blank?

      query = +"text = CONCAT(text, ?)"
      args = [atext]

      if (distros = extract_successfull_distro_ids(atext)).any?
        query << ", successfull_distro_ids = ARRAY_CAT(successfull_distro_ids, ARRAY[?])"
        args << distros
      end
      if (distros = extract_failed_distro_ids(atext)).any?
        query << ", failed_distro_ids = ARRAY_CAT(failed_distro_ids, ARRAY[?])"
        args << distros
      end

      self.class.where(id: id).update_all([query, *args]) # rubocop: disable Rails/SkipsModelValidations
      ::Broadcasts::TaskLog.new(self).append(atext)
    end

    private

    def set_progress_distro_ids
      self.successfull_distro_ids = extract_successfull_distro_ids(text)
      self.failed_distro_ids = extract_failed_distro_ids(text)
    end

    def extract_successfull_distro_ids(string)
      string.scan(/successfully finished build for (.+) in/).flatten.compact
    end

    def extract_failed_distro_ids(string)
      string.scan(/failed build for (.+) in/).flatten.compact
    end
  end
end
