class UniqUnidexOnProjectUserSlug < ActiveRecord::Migration[7.2]
  def change
    reversible do |dir|
      dir.up do
        remove_index :projects, :slug
      end
      dir.down do
        add_index :projects, :slug, unique: true
      end
    end
    add_index :projects, [:user_id, :slug], unique: true
  end
end
