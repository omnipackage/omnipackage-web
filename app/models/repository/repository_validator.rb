# frozen_string_literal: true

class Repository
  class RepositoryValidator < ::ActiveModel::Validator
    def validate(record)
      reachable(record)
    end

    private

    def reachable(record)
      record.storage.client.ls_buckets.map(&:name)
    rescue ::StandardError => e
      record.errors.add(:bucket, e.message)
    end
  end
end
