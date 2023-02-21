class AddSourcesVerifiedAtToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :sources_verified_at, :datetime, null: true, default: nil
  end
end
