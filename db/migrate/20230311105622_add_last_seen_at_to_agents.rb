class AddLastSeenAtToAgents < ActiveRecord::Migration[7.1]
  def change
    add_column :agents, :last_seen_at, :datetime, null: true, default: nil
  end
end
