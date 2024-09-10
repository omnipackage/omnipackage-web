# frozen_string_literal: true

class DeleteBucketJob < ::ApplicationJob
  queue_as :default

  def perform(storage_client_config, bucket)
    ::StorageClient.new(storage_client_config).delete_bucket!(bucket: bucket)
  end
end
