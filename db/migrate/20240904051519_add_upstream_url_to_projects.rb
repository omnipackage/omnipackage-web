class AddUpstreamUrlToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :upstream_url, :string, limit: 1000, null: true
  end
end
