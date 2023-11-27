class AddPublishStatusToRepositories < ActiveRecord::Migration[7.1]
  def change
    add_column :repositories, :publish_status, :string, null: false, default: ''
  end
end
