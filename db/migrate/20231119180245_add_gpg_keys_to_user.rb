class AddGpgKeysToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :gpg_key_private, :string, null: true
    add_column :users, :gpg_key_public, :string, null: true
  end
end
