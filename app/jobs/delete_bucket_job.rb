# frozen_string_literal: true

class DeleteBucketJob < ::ApplicationJob
  queue_as :default
  retry_on ::StandardError, wait: :polynomially_longer, attempts: 10

  def perform(storage_client_config, bucket)
    ::StorageClient.new(storage_client_config.symbolize_keys).delete_bucket!(bucket: bucket)
  end
end
