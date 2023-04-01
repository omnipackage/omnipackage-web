class CreateTaskArtefacts < ActiveRecord::Migration[7.1]
  def change
    create_table :task_artefacts do |t|
      t.string :distro, null: false
      t.references :task, null: false, foreign_key: true

      t.timestamps
    end
  end
end
