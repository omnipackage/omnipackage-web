# frozen_string_literal: true

class DeleteFilesJob < ::ApplicationJob
  queue_as :default
  retry_on ::StandardError, wait: :polynomially_longer, attempts: 10

  def perform(storage_client_config, bucket, path)
    ::StorageClient.new(storage_client_config).delete_files!(bucket: bucket, prefix: path)
  end
end
