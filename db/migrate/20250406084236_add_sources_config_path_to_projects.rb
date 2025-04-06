class AddSourcesConfigPathToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :sources_config_path, :string, limit: 4096, null: true
  end
end
