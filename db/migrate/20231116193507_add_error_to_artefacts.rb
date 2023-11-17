class AddErrorToArtefacts < ActiveRecord::Migration[7.1]
  def change
    add_column :task_artefacts, :error, :boolean, null: false, default: false
  end
end
