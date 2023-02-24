class RemoveSourcesVerifiedAt < ActiveRecord::Migration[7.1]
  def up
    remove_column :projects, :sources_verified_at
  end

  def down
    add_column :projects, :sources_verified_at, :datetime, null: true, default: nil
  end
end
