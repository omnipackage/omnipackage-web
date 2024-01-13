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

  attr_reader :config

  def initialize(config = {})
    @config = {
      force_path_style:   config.fetch(:force_path_style, false),
      access_key_id:      config.fetch(:access_key_id),
      secret_access_key:  config.fetch(:secret_access_key),
      region:             config.fetch(:region),
      endpoint:           config.fetch(:endpoint, nil)
    }
    @c = ::Aws::S3::Resource.new(client: ::Aws::S3::Client.new(**@config))
  end

  def ls_buckets
    c.buckets
  end

  def ls(bucket:)
    c.bucket(bucket).objects
  end

  def download_dir(bucket:, to:)
    ls(bucket: bucket).each do |object|
      dirs = object.key.split('/')[0..-2]

      if dirs.any?
        fdir = ::Pathname.new(to).join(*dirs)
        ::FileUtils.mkdir_p(fdir) unless ::File.exist?(fdir)
      end

      object.get(response_target: ::Pathname.new(to).join(object.key))
    end
  end

  def upload_dir(bucket:, from:)
    ::Dir.glob(::Pathname.new(from).join('**/*')).each do |fpath|
      next if ::File.directory?(fpath)

      key = fpath.gsub(from, '')
      key = key[1..-1] if key.start_with?('/')

      upload(bucket: bucket, from: fpath, key: key)
    end
  end

  def upload(bucket:, from:, key:)
    ::File.open(from, 'rb') do |file|
      c.bucket(bucket).object(key).put(body: file)
    end
  end

  def get_policy(bucket:)
    ::JSON.parse(c.bucket(bucket).policy.policy.read)
  end

  def set_policy(bucket:, policy:)
    c.client.put_bucket_policy(bucket: bucket, policy: ::JSON.dump(policy))
  end

  def set_allow_public_read(bucket:) # rubocop: disable Metrics/MethodLength
    policy = {
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Effect" => "Allow",
          "Principal" => { "AWS" => ["*"] },
          "Action" => ["s3:GetBucketLocation", "s3:ListBucket"],
          "Resource" => ["arn:aws:s3:::#{bucket}"]
        },
        {
          "Effect" => "Allow",
          "Principal" => { "AWS" => ["*"] },
          "Action" => ["s3:GetObject"],
          "Resource" => ["arn:aws:s3:::#{bucket}/*"]
        }
      ]
    }
    set_policy(bucket: bucket, policy: policy)
  end

  def create_bucket(bucket:)
    c.bucket(bucket).create
  end

  def bucket_exists?(bucket:)
    c.bucket(bucket).exists?
  end

  def delete_bucket!(bucket:)
    if bucket_exists?(bucket: bucket)
      c.bucket(bucket).delete!
    end
  end

  def url(bucket:)
    c.bucket(bucket).url
  end

  private

  attr_reader :c
end
