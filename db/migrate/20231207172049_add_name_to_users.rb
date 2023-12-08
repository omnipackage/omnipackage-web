class AddNameToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :name, :string, limit: 2000, null: false, default: ''
  end
end
