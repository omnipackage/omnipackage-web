class Task
  class Log < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'

    before_save :set_progress_distro_ids, if: :text_changed?

    DistroIds = ::Data.define(:successfull, :failed) do
      def self.build(string)
        new(
          successfull: extract(string, /successfully finished build for (.+) in/),
          failed: extract(string, /failed build for (.+) in/)
        )
      end

      def self.extract(string, regex)
        (string.scan(regex).flatten.compact & ::Distro.ids).freeze
      end
    end

    def append(atext) # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
      return if atext.blank?

      query = "text = CONCAT(text, ?)"
      args = [atext]

      d = DistroIds.build(atext)
      if d.successfull.any?
        query += ", successfull_distro_ids = ARRAY_CAT(successfull_distro_ids, ARRAY[?])"
        args << d.successfull
      end
      if d.failed.any?
        query += ", failed_distro_ids = ARRAY_CAT(failed_distro_ids, ARRAY[?])"
        args << d.failed
      end

      self.class.where(id: id).update_all([query, *args]) # rubocop: disable Rails/SkipsModelValidations
      ::Broadcasts::TaskLog.new(self).append(atext)
    end

    def distro_ids
      DistroIds.new(successfull_distro_ids, failed_distro_ids)
    end

    private

    def set_progress_distro_ids
      self.successfull_distro_ids, self.failed_distro_ids = DistroIds.build(text).deconstruct
    end
  end
end
