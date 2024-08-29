# frozen_string_literal: true

class Repository
  class Storage
    attr_reader :client, :bucket, :path

    FileItem = ::Data.define(:key, :size, :last_modified_at, :url)

    def initialize(client, bucket, path)
      @client = client
      @bucket = bucket
      @path = path
    end

    def download_all(to:)
      client.download_dir(bucket: bucket, to:, from: path)
    end

    def upload_all(from:)
      client.upload_dir(bucket: bucket, from:, to: path)
    end

    def delete_deleted_files(from:)
      client.ls(bucket: bucket, prefix: path).each do |fo|
        local_path = ::Pathname.new(from).join(fo.key).to_s.sub(path, '')
        fo.delete unless ::File.exist?(local_path)
      end
    end

    def bucket_exists?
      client.bucket_exists?(bucket: bucket)
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
      client.create_bucket(bucket: bucket)
    end

    def allow_public_read!
      client.set_allow_public_read(bucket: bucket)
    end

    def url
      client.url(bucket: bucket) + '/' + path
    end

    def ls # rubocop: disable Metrics/AbcSize
      return [] unless bucket_exists?

      fn = path.end_with?('/') ? path : path + '/'
      client.ls(bucket: bucket, prefix: path).map { |i| FileItem[i.key.sub(fn, ''), i.size, i.last_modified, i.public_url] }
    end
  end
end
