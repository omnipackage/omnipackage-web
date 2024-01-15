# frozen_string_literal: true

class Repository
  class RepositoryValidator < ::ActiveModel::Validator
    def validate(record)
      uniq_bucket(record)
      reachable(record)
    end

    private

    def uniq_bucket(record)
      if record.changes.include?(:bucket) && !record.custom_storage? && record.storage_client.ls_buckets.any? { |b| b.name == record.bucket }
        record.errors.add(:bucket, 'bucket already exists in the storage')
      end
    rescue ::StandardError => e
      record.errors.add(:bucket, e.message)
    end

    def reachable(record)
      record.storage_client.ls(bucket: record.bucket)
    rescue ::StandardError => e
      record.errors.add(:bucket, e.message)
    end
  end
end
