class AddUniqIndexToProjectSourcesTarballs < ActiveRecord::Migration[7.1]
  def up
    remove_index :project_sources_tarballs, :project_id
    add_index :project_sources_tarballs, :project_id, unique: true
  end

  def down
    remove_index :project_sources_tarballs, :project_id
    add_index :project_sources_tarballs, :project_id
  end
end
