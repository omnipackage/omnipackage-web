class AddProgress2ToTaskLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :task_logs, :failed_distro_ids, :string, array: true, null: false, default: []
  end
end
