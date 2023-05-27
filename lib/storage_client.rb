# frozen_string_literal: true

class StorageClient
  class << self
    def build_default # rubocop: disable Metrics/AbcSize
      as_client = ::ActiveStorage::Blob.service.client.client
      raise "must be S3 service client (#{as_client.class})" unless as_client.is_a?(::Aws::S3::Client)

      as_service = ::Rails.application.config.active_storage.service.to_s
      as_config = ::Rails.application.config.active_storage.service_configurations[as_service].symbolize_keys
      raise "must be S3 service (#{as_config[:service]})" if as_config[:service] != 'S3'

      new(as_config)
    end
  end

  def initialize(config = {})
    args = {
      force_path_style:   true,
      access_key_id:      config.fetch(:access_key_id),
      secret_access_key:  config.fetch(:secret_access_key),
      region:             config.fetch(:region),
      endpoint:           config.fetch(:endpoint, nil)
    }
    @c = ::Aws::S3::Resource.new(client: ::Aws::S3::Client.new(**args))

    # @c = ::ActiveStorage::Blob.service.client.client
    # raise "must be S3 service (#{c.class})" unless c.is_a?(::Aws::S3::Client)

    # c.get_object(
    #  bucket: 'artefacts',
    #  key: '4aemzyinq56tufyhkdcdyioxr3qf',
    #  response_target: 'download_testobject'
    # )
  end

  def ls(bucket:)
    b = c.bucket(bucket)
    b.objects
    #c.list_objects(bucket: bucket, max_keys: 1000)
  end

  private

  attr_reader :c
end
