class AddSourceToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :sources_location, :string, null: false, default: ''
    add_column :projects, :sources_kind, :string, null: false, default: ''
    add_column :projects, :sources_ssh_key, :string, null: false, default: ''

    add_index :projects, :sources_kind
  end
end
