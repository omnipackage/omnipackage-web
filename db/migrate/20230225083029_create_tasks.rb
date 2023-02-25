class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :sources_tarball, null: false, foreign_key: { to_table: :project_sources_tarballs }
      t.string :state, null: false, default: '', index: true

      t.timestamps
    end
  end
end
