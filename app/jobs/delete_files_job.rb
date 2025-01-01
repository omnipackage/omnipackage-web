class DeleteFilesJob < ::ApplicationJob
  queue_as :default

  def perform(storage_client_config, bucket, path)
    ::StorageClient.new(storage_client_config).delete_files!(bucket: bucket, prefix: path)
  end
end
