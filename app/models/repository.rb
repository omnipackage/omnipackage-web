# frozen_string_literal: true

class Repository < ::ApplicationRecord
  belongs_to :project

  validates :distro_id, inclusion: { in: ::Distro.ids }

  def distro
    ::Distro[distro_id]
  end

  def storage_client
    if access_key_id && secret_access_key
      ::StorageClient.new(endpoint: endpoint, access_key_id: access_key_id, secret_access_key: secret_access_key, region: region)
    else
      ::StorageClient.build_default
    end
  end

  def download_all(to:)
    storage_client.download_dir(bucket: bucket, to: to)
  end

  def upload_all(from:)
    storage_client.upload_dir(bucket: bucket, from: from)
  end

  def make_public_readable! # rubocop: disable Metrics/MethodLength
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
    storage_client.set_policy(bucket: bucket, policy: policy)
  end

  def create_bucket!
    storage_client.create_bucket(bucket: bucket)
  end
end
