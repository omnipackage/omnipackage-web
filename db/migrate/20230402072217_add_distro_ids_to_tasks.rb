class AddDistroIdsToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :distro_ids, :string, array: true, null: false
  end
end
