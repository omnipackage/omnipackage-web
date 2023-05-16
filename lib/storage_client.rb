# frozen_string_literal: true

class StorageClient
  def initialize
    as_service = ::Rails.application.config.active_storage.service.to_s
    as_config = ::Rails.application.config.active_storage.service_configurations[as_service]
    raise "must be S3 service (#{as_config['service']})" if as_config['service'] != 'S3'

    @c = ::Aws::S3::Client.new(
      endpoint:           as_config['endpoint'],
      access_key_id:      as_config['access_key_id'],
      secret_access_key:  as_config['secret_access_key'],
      force_path_style:   true,
      region:             as_config['region']
    )

    # @c = ::ActiveStorage::Blob.service.client.client
    # raise "must be S3 service (#{c.class})" unless c.is_a?(::Aws::S3::Client)

    # c.get_object(
    #  bucket: 'artefacts',
    #  key: '4aemzyinq56tufyhkdcdyioxr3qf',
    #  response_target: 'download_testobject'
    # )
  end

  private

  attr_reader :c
end
