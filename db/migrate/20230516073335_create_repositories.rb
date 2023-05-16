class CreateRepositories < ActiveRecord::Migration[7.1]
  def change
    create_table :repositories do |t|
      t.references :project, null: false, foreign_key: true
      t.string :distro_id, null: false, index: true
      t.string :bucket, null: false, index: true
      t.string :endpoint, null: true
      t.string :access_key_id, null: true
      t.string :secret_access_key, null: true
      t.string :region, null: true

      t.timestamps
    end
  end
end
