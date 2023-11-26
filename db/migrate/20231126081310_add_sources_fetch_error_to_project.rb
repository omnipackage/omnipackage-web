class AddSourcesFetchErrorToProject < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :sources_fetch_error, :string, limit: 10000, null: true
  end
end
