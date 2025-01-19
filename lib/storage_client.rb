class StorageClient
  class Config < ::Hash
    class << self
      def default
        as_config = activestorage
        raise "must be S3 service (#{as_config[:service]})" if as_config[:service] != 'S3'

        new(as_config)
      end

      def activestorage # rubocop: disable Metrics/AbcSize
        as_client = ::ActiveStorage::Blob.service.client.client
        raise "must be S3 service client (#{as_client.class})" unless as_client.is_a?(::Aws::S3::Client)

        as_service = ::Rails.application.config.active_storage.service.to_s
        ::Rails.application.config.active_storage.service_configurations[as_service].symbolize_keys
      end

      def reserved_buckets
        [activestorage.fetch(:bucket)].freeze
      end
    end

    def initialize(hash)
      super()
      hash = hash.symbolize_keys
      self[:force_path_style] = hash.fetch(:force_path_style, true)
      self[:access_key_id] = hash.fetch(:access_key_id)
      self[:secret_access_key] = hash.fetch(:secret_access_key)
      self[:region] = hash.fetch(:region)
      self[:endpoint] = hash.fetch(:endpoint)
      freeze
    end

    def method_missing(method_name, *arguments, &)
      self[method_name.to_sym] || super
    end

    def respond_to_missing?(method_name, include_private = false)
      kay?(method_name.to_sym) || super
    end

    def build_url(*parts)
      ::PathUtil.join(endpoint, *parts)
    end
  end

  attr_reader :config

  def initialize(config)
    @config = ::StorageClient::Config.new(config)
    @c = ::Aws::S3::Resource.new(client: ::Aws::S3::Client.new(**@config))
    freeze
  end

  def ls_buckets
    c.buckets
  end

  def ls(bucket:, prefix: '')
    c.bucket(bucket).objects(prefix: normalize_remote_path(prefix))
  end

  def download_dir(bucket:, to:, from: '') # rubocop: disable Metrics/MethodLength
    from = normalize_remote_path(from)
    ls(bucket:, prefix: from).each do |object|
      key = object.key
      key = key.sub(from, '') if from.present?
      dirs = key.split('/')[0..-2]

      if dirs.any?
        fdir = ::Pathname.new(to).join(*dirs)
        ::FileUtils.mkdir_p(fdir)
      end

      object.get(response_target: ::Pathname.new(to).join(key))
    end
  end

  def upload_dir(bucket:, from:, to: '')
    ::Dir.glob(::Pathname.new(from).join('**/*')).each do |fpath|
      next if ::File.directory?(fpath)

      key = fpath.gsub(from, to)
      key = key[1..-1] if key.start_with?('/')

      upload(bucket:, from: fpath, key: key)
    end
  end

  def upload(bucket:, from:, key:, content_type: nil)
    ::File.open(from, 'rb') do |file|
      c.bucket(bucket).object(key).put(**{ body: file, content_type: }.compact)
    end
  end

  def get_policy(bucket:)
    ::JSON.parse(c.bucket(bucket).policy.policy.read)
  end

  def set_policy(bucket:, policy:)
    c.client.delete_public_access_block(bucket:) if config[:endpoint].end_with?('amazonaws.com') # hack for aws
    c.client.put_bucket_policy(bucket:, policy: ::JSON.dump(policy))
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
    set_policy(bucket:, policy:)
  end

  def create_bucket(bucket:)
    c.bucket(bucket).create
  end

  def bucket_exists?(bucket:)
    c.bucket(bucket).exists?
  end

  def delete_bucket!(bucket:)
    if bucket_exists?(bucket:)
      c.bucket(bucket).delete!
    end
  end

  def url(bucket:)
    c.bucket(bucket).url
  end

  def delete_files!(bucket:, prefix:)
    c.bucket(bucket).objects(prefix:).batch_delete!
  end

  private

  attr_reader :c

  def normalize_remote_path(rpath)
    rpath += '/' if rpath.present? && !rpath.end_with?('/')
    rpath = '' if rpath == '/'
    rpath
  end
end
