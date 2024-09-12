# frozen_string_literal: true

class Task
  class Log < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'

    before_save :set_progress_distro_ids, if: :text_changed?

    class DistroIds
      attr_reader :successfull, :failed

      def initialize(string)
        @successfull = extract(string, /successfully finished build for (.+) in/)
        @failed = extract(string, /failed build for (.+) in/)
      end

      def deconstruct
        [successfull, failed]
      end

      private

      def extract(string, regex)
        string.scan(regex).flatten.compact & ::Distro.ids
      end
    end

    def append(atext) # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
      return if atext.blank?

      query = "text = CONCAT(text, ?)"
      args = [atext]

      distro_ids = DistroIds.new(atext)
      if distro_ids.successfull.any?
        query += ", successfull_distro_ids = ARRAY_CAT(successfull_distro_ids, ARRAY[?])"
        args << distro_ids.successfull
      end
      if distro_ids.failed.any?
        query += ", failed_distro_ids = ARRAY_CAT(failed_distro_ids, ARRAY[?])"
        args << distro_ids.failed
      end

      self.class.where(id: id).update_all([query, *args]) # rubocop: disable Rails/SkipsModelValidations
      ::Broadcasts::TaskLog.new(self).append(atext)
    end

    private

    def set_progress_distro_ids
      self.successfull_distro_ids, self.failed_distro_ids = DistroIds.new(text).deconstruct
    end
  end
end
