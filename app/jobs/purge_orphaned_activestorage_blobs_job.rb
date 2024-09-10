# frozen_string_literal: true

class PurgeOrphanedActivestorageBlobsJob < ::ApplicationJob
  queue_as :long

  def perform # rubocop: disable Metrics/MethodLength
    config = ::StorageClient::Config.activestorage
    client = ::StorageClient.new(config)
    removed_files = 0
    client.ls(bucket: config.fetch(:bucket)).each do |fo|
      next if ::ActiveStorage::Blob.exists?(key: fo.key)

      ::Rails.error.handle do
        fo.delete
        removed_files += 1
      end
    end
    ::Rails.logger.info("pruned #{removed_files} from activestorage")
  end
end
