# frozen_string_literal: true

class CreatePasswordResetTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :password_reset_tokens do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
