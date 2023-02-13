# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email,           null: false
      t.string :password_digest, null: false

      t.datetime :verified_at, null: true

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
