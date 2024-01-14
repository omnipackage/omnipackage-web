# frozen_string_literal: true

class Repository
  class RepositoryValidator < ::ActiveModel::Validator
    def validate(record)
      uniq_bucket(record)
    end

    private

    def uniq_bucket(record) # rubocop: disable Metrics/AbcSize
      if record.changes.include?(:bucket) && !record.custom_storage? && record.storage_client.ls_buckets.any? { |b| b.name == record.bucket }
        record.errors.add(:bucket, 'bucket already exists in the storage')
      end
    rescue ::StandardError => e
      record.errors.add(:bucket, e.message) unless ::Rails.env.test?
    end
  end
end
