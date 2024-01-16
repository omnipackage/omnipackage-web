# frozen_string_literal: true

class Repository
  class RepositoryValidator < ::ActiveModel::Validator
    def validate(record)
      return unless record.custom_storage?

      bucket_only_custom_storate(record)
      reachable(record)
    end

    private

    def bucket_only_custom_storate(record)
      if record.changes.include?(:bucket)
        record.errors.add(:bucket, 'cannot change bucket when using built-in storage')
      end
    end

    def reachable(record)
      record.storage_client.ls_buckets.map(&:name)
    rescue ::StandardError => e
      record.errors.add(:bucket, e.message)
    end
  end
end
