class RenameProjectRepositoryStorage < ActiveRecord::Migration[7.2]
  def change
    rename_table :project_repository_storages, :project_custom_repository_storages
    add_index :project_custom_repository_storages, [:endpoint, :bucket, :path], unique: true
  end
end
