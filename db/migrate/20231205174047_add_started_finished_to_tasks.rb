class AddStartedFinishedToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :started_at, :datetime, null: true
    add_column :tasks, :finished_at, :datetime, null: true
  end
end
