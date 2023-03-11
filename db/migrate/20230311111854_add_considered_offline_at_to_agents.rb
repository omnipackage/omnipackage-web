class AddConsideredOfflineAtToAgents < ActiveRecord::Migration[7.1]
  def change
    add_column :agents, :considered_offline_at, :datetime, null: true, default: nil
  end
end
