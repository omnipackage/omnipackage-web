class MoveCustomStorageToProjects < ActiveRecord::Migration[7.2]
  def change
    reversible do |dir|
      dir.up do
        remove_columns :repositories, :bucket, :endpoint, :access_key_id, :secret_access_key, :region, :custom_storage
      end

      dir.down do
        change_table :repositories do |t|
          t.string :bucket, null: true, index: true
          t.string :endpoint, null: true
          t.string :access_key_id, null: true
          t.string :secret_access_key, null: true
          t.string :region, null: true
          t.boolean :custom_storage, default: false, null: false

          t.index [:endpoint, :bucket], unique: true
        end
        execute "UPDATE repositories SET bucket = CONCAT('todo-change-me', '-', id)"
        change_column_null :repositories, :bucket, false
      end
    end

    create_table :project_repository_storages do |t|
      t.references :project, null: false, foreign_key: true, index: true
      t.string :bucket, null: false, index: true
      t.string :path, null: false, default: ''
      t.string :endpoint, null: false, index: true
      t.string :access_key_id, null: false
      t.string :secret_access_key, null: false
      t.string :region, null: false
      t.timestamps

      t.index [:endpoint, :bucket], unique: true
    end
  end
end
