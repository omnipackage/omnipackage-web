class CreateTaskStats < ActiveRecord::Migration[7.1]
  def change
    create_table :task_stats do |t|
      t.references :task, null: false, foreign_key: true, index: true

      t.float :total_time, null: false, default: 0
      t.float :lockwait_time, null: false, default: 0
      t.virtual :build_time, type: :float, as: 'total_time - lockwait_time', stored: true

      t.timestamps
    end
  end
end
