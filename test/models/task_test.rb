# frozen_string_literal: true

require 'test_helper'

class TaskTest < ::ActiveSupport::TestCase
  test 'factory and validation' do
    o = create(:task)
    assert o.valid?
    assert o.sources_tarball.valid?
    assert_equal 'pending_fetch', o.state
    assert_equal o.project, o.sources_tarball.project

    assert build(:task, sources_tarball: nil).invalid?
    assert build(:task, distro_ids: ['ololo']).invalid?
    assert build(:task, distro_ids: []).invalid?
    assert build(:task, distro_ids: nil).invalid?
  end

  test 'create' do
    project = create(:project_with_sources)
    ::Task.start(project)

    assert_equal 1, project.tasks.count
  end
end
