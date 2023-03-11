class AddRootToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :root, :boolean, null: false, default: false
    add_reference :agents, :user, index: true, foreign_key: true
  end
end
