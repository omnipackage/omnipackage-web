# frozen_string_literal: true

class Repository < ::ApplicationRecord
  belongs_to :project
  has_one :user, through: :project, class_name: '::User'

  validates :distro_id, inclusion: { in: ::Distro.ids }
  validates :gpg_key_private, :gpg_key_public, presence: true, allow_nil: true
  validates :bucket, format: /(?!(^xn--|.+-s3alias$))^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]\z/, uniqueness: { scope: :endpoint }

  encrypts :gpg_key_private

  # after_commit :delete_bucket!, on: :destroy

  FileItem = ::Data.define(:key, :size, :last_modified_at, :url)

  def distro
    ::Distro[distro_id]
  end

  def distro=(dist)
    self.distro_id = dist.id
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

  def delete_deleted_files(from:)
    storage_client.ls(bucket: bucket).each do |fo|
      local_path = ::Pathname.new(from).join(fo.key)
      fo.delete unless ::File.exist?(local_path)
    end
  end

  def bucket_exists?
    storage_client.bucket_exists?(bucket: bucket)
  end

  def create_bucket_if_not_exists!
    return if bucket_exists?

    storage_client.create_bucket(bucket: bucket)
    storage_client.set_allow_public_read(bucket: bucket)
  end

  def delete_bucket!
    storage_client.delete_bucket!(bucket: bucket)
  end

  def url
    storage_client.url(bucket: bucket)
  end

  def ls
    return [] unless bucket_exists?

    storage_client.ls(bucket: bucket).map { |i| FileItem[i.key, i.size, i.last_modified, i.public_url] }
  end

  def gpg_key
    if gpg_key_private && gpg_key_public
      ::Gpg::Key[gpg_key_private, gpg_key_public]
    else
      user.gpg_key
    end
  end

  def installable_package_name
    project.installable_package_name(distro.id)
  end

  def installable_cli
    distro.install_steps.map do |command|
      format(command, project_safe_name: project.safe_name, installable_package_name: installable_package_name, url: url)
    end.join("\n")
  end
end
