class AddPublishedAtToRepositories < ActiveRecord::Migration[7.1]
  def change
    add_column :repositories, :published_at, :datetime, null: true, default: nil
    add_column :repositories, :last_publish_error, :string, null: true, default: nil
  end
end
