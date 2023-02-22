class BothSshKeysInProject < ActiveRecord::Migration[7.1]
  def change
    rename_column :projects, :sources_ssh_key, :sources_private_ssh_key
    add_column :projects, :sources_public_ssh_key, :string, null: true
    change_column_null :projects, :sources_private_ssh_key, true
    change_column_default :projects, :sources_private_ssh_key, from: '', to: nil
  end
end
