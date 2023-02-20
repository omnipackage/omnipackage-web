class Remove < ActiveRecord::Migration[7.1]
  def up
    drop_table :project_distros
  end

  def down
    create_table :project_distros do |t|
      t.references :project, null: false, foreign_key: true
      t.string :distro_id, null: false, default: ''

      t.timestamps
    end

    add_index :project_distros, :distro_id
  end
end
