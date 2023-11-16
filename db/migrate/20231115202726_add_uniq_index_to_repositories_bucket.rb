class AddUniqIndexToRepositoriesBucket < ActiveRecord::Migration[7.1]
  def change
    add_index :repositories, [:endpoint, :bucket], unique: true
  end
end
