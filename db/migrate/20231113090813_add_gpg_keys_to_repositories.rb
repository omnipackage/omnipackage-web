class AddGpgKeysToRepositories < ActiveRecord::Migration[7.1]
  def change
    add_column :repositories, :gpg_key_private, :string, null: true
    add_column :repositories, :gpg_key_public, :string, null: true
  end
end
