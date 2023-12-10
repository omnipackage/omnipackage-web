class CreateWebhooks < ActiveRecord::Migration[7.1]
  def change
    create_table :webhooks do |t|
      t.string :key, null: false, limit: 1000
      t.string :secret, null: true, limit: 1000
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end

    add_index :webhooks, :key, unique: true
  end
end
