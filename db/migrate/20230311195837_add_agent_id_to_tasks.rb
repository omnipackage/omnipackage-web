class AddAgentIdToTasks < ActiveRecord::Migration[7.1]
  def change
    add_reference :tasks, :agent, null: true, foreign_key: true
  end
end
