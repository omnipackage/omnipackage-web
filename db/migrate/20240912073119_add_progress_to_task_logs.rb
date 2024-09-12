class AddProgressToTaskLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :task_logs, :successfull_distro_ids, :string, array: true, null: false, default: []
  end
end
