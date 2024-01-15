class AddDefaultStorageToRepositories < ActiveRecord::Migration[7.1]
  def change
    add_column :repositories, :custom_storage, :boolean, null: false, default: false
  end
end
