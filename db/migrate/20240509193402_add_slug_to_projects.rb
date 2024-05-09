class AddSlugToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :slug, :string, limit: 120, null: false
    add_index :projects, :slug, unique: true 
  end
end
