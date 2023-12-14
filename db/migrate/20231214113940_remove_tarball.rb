class RemoveTarball < ActiveRecord::Migration[7.1]
  def up
    remove_column :project_sources_tarballs, :tarball
  end

  def down
    change_table :project_sources_tarballs do |t|
      t.binary :tarball
    end
  end
end
