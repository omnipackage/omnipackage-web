class AddInstallableFilenameToRespositories < ActiveRecord::Migration[7.2]
  def change
    add_column :repositories, :installable_filename, :string, null: true, default: nil
  end
end
