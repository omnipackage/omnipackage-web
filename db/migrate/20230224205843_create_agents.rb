class CreateAgents < ActiveRecord::Migration[7.1]
  def change
    create_table :agents do |t|
      t.string :apikey, null: false

      t.timestamps
    end

    add_index :agents, :apikey, unique: true
  end
end
