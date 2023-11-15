class AddArchToAgents < ActiveRecord::Migration[7.1]
  def change
    add_column :agents, :arch, :string, limit: 100, null: false
  end
end
