class AddSourcesSubdirToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :sources_subdir, :string, null: false, default: ''
  end
end
