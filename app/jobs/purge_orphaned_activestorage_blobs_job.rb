class PurgeOrphanedActivestorageBlobsJob < ::ApplicationJob
  queue_as :long

  def perform
    removed_files = 0
    files_in_storage.each do |fo|
      next if ::ActiveStorage::Blob.exists?(key: fo.key)

      ::Rails.error.handle do
        fo.delete
        removed_files += 1
      end
    end
    ::Rails.logger.info("pruned #{removed_files} from activestorage")
  end

  private

  def files_in_storage
    config = ::StorageClient::Config.activestorage
    client = ::StorageClient.new(config)
    client.ls(bucket: config.fetch(:bucket))
  end
end
