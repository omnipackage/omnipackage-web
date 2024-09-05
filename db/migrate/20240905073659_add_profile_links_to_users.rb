class AddProfileLinksToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :profile_links, :string, array: true, limit: 500, null: false, default: []
  end
end
