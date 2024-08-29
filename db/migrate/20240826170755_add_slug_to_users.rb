class AddSlugToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :slug, :string, limit: 120, null: true
    add_index :users, :slug, unique: true
    reversible do |dir|
      dir.up do
        execute "UPDATE users SET slug = CONCAT('change-me-', email)"
      end
    end
    change_column_null :users, :slug, false
  end
end
