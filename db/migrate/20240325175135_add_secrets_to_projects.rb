class AddSecretsToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :secrets, :string
  end
end
