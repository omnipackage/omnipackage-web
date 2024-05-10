# frozen_string_literal: true

class Repository
  class Storage
    attr_reader :client, :bucket

    FileItem = ::Data.define(:key, :size, :last_modified_at, :url)

    def initialize(client, bucket)
      @client = client
      @bucket = bucket
    end

    def download_all(to:)
      client.download_dir(bucket: bucket, to: to)
    end

    def upload_all(from:)
      client.upload_dir(bucket: bucket, from: from)
    end

    def delete_deleted_files(from:)
      client.ls(bucket: bucket).each do |fo|
        local_path = ::Pathname.new(from).join(fo.key)
        fo.delete unless ::File.exist?(local_path)
      end
    end

    def bucket_exists?
      client.bucket_exists?(bucket: bucket)
    end

    def create_bucket_if_not_exists!
      return if bucket_exists?

      client.create_bucket(bucket: bucket)

      1.upto(10) do # wtf minio?
        if bucket_exists?
          client.set_allow_public_read(bucket: bucket)
          break
        end
        sleep(1)
      end
    end

    def delete_bucket!
      client.delete_bucket!(bucket: bucket)
    end

    def url
      client.url(bucket: bucket)
    end

    def ls
      return [] unless bucket_exists?

      client.ls(bucket: bucket).map { |i| FileItem[i.key, i.size, i.last_modified, i.public_url] }
    end
  end
end
