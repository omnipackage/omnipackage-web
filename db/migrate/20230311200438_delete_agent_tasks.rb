class DeleteAgentTasks < ActiveRecord::Migration[7.1]
  def up
    drop_table :agent_tasks
  end

  def down
    create_table :agent_tasks do |t|
      t.references :agent, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true
      t.string :state, null: false, index: true

      t.timestamps
    end
  end
end
