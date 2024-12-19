class TaskReferenceProject < ActiveRecord::Migration[8.0]
  def change
    add_reference :tasks, :project, index: true, foreign_key: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
        UPDATE tasks t
        SET project_id = s.project_id
        FROM project_sources_tarballs s
        WHERE t.sources_tarball_id = s.id
        SQL
        change_column_null :tasks, :sources_tarball_id, true
        change_column_null :tasks, :project_id, false
      end

      dir.down do
      end
    end
  end
end
