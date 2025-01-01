class Repository
  class Storage
    FileItem = ::Data.define(:key, :size, :last_modified_at, :url)

    Config = ::Data.define(:client_config, :bucket, :bucket_public_url, :path) do
      def self.default
        new(
          client_config: ::StorageClient::Config.default,
          bucket: ::APP_SETTINGS.fetch(:repositories).fetch(:bucket),
          bucket_public_url: ::APP_SETTINGS.fetch(:repositories).fetch(:bucket_public_url, nil),
          path: ''
        )
      end

      def append_path(*arg)
        self.class.new(client_config:, bucket:, bucket_public_url:, path: ::PathUtil.join(path, *arg))
      end

      def url
        url_to_public(client_config.build_url(bucket, path))
      end

      def url_to_public(arg)
        return arg if bucket_public_url.blank?

        private_url = client_config.build_url(bucket)
        arg.gsub(private_url, bucket_public_url)
      end
    end

    attr_reader :client, :config

    delegate :bucket, :path, :url, to: :config

    def initialize(config)
      @config = config
      @client = ::StorageClient.new(config.client_config)
      freeze
    end

    def ping!
      client.ls_buckets.map(&:name)
    end

    def download_all(to:)
      client.download_dir(bucket:, to:, from: path)
    end

    def upload_all(from:)
      client.upload_dir(bucket:, from:, to: path)
    end

    def delete_deleted_files(from:)
      client.ls(bucket:, prefix: path).each do |fo|
        local_path = ::Pathname.new(from).join(fo.key).to_s.sub(path, '').sub('//', '/')
        fo.delete unless ::File.exist?(local_path)
      end
    end

    def bucket_exists?
      client.bucket_exists?(bucket:)
    end

    def create_bucket_if_not_exists!
      return if bucket_exists?

      create_bucket!

      1.upto(15) do # wtf minio?
        if bucket_exists?
          allow_public_read!
          break
        end
        sleep(1)
      end
    end

    def create_bucket!
      client.create_bucket(bucket:)
    end

    def allow_public_read!
      client.set_allow_public_read(bucket:)
    end

    def ls # rubocop: disable Metrics/AbcSize
      return [] unless bucket_exists?

      fn = path.end_with?('/') ? path : path + '/'

      client.ls(bucket:, prefix: path).map do |i|
        FileItem.new(
          key: i.key.sub(fn, ''),
          size: i.size,
          last_modified_at: i.last_modified,
          url: config.url_to_public(i.public_url)
        )
      end
    end
  end
end
