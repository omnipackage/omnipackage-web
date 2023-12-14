class AddSourcesBranchToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :sources_branch, :string, null: false, default: ''
  end
end
