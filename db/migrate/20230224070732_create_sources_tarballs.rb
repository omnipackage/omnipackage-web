class CreateSourcesTarballs < ActiveRecord::Migration[7.1]
  def change
    create_table :project_sources_tarballs do |t|
      t.binary :tarball
      t.json :config
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
