class CreateTaskLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :task_logs do |t|
      t.references :task, null: false, foreign_key: true, index: true
      t.text :text, limit: 100_000_000, null: false, default: '' 

      t.timestamps
    end
  end
end
