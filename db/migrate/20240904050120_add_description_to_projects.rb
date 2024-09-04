class AddDescriptionToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :description, :string, limit: 1000, null: true
  end
end
