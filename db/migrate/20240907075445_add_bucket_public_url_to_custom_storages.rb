class AddBucketPublicUrlToCustomStorages < ActiveRecord::Migration[7.2]
  def change
    add_column :project_custom_repository_storages, :bucket_public_url, :string, limit: 2000, null: true
  end
end
