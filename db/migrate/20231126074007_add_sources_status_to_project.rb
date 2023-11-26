class AddSourcesStatusToProject < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :sources_status, :string, default: '', null: false
    add_index :projects, :sources_status
  end
end
