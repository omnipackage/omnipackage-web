class AddDebounceToWebhooks < ActiveRecord::Migration[8.1]
  def change
    change_table :webhooks do |t|
      t.interval :debounce, default: 0, null: false

      t.datetime :last_trigger_at
    end

    up_only do
      execute <<~SQL
      UPDATE webhooks SET debounce = 'PT60S'
      SQL
    end
  end
end
