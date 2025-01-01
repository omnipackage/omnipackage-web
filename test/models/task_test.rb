require 'test_helper'

class TaskTest < ::ActiveSupport::TestCase
  test 'factory and validation' do
    o = create(:task)
    assert o.valid?
    assert o.sources.present?
    assert_equal 'pending_fetch', o.state

    assert build(:task, sources: nil, state: 'pending_build').invalid?
    assert build(:task, sources: nil, state: 'pending_fetch').valid?
    assert build(:task, distro_ids: ['ololo']).invalid?
    assert build(:task, distro_ids: []).invalid?
    assert build(:task, distro_ids: nil).invalid?
  end

  test 'create' do
    project = create(:project_with_sources)
    ::Task::Starter.new(project).call

    assert_equal 1, project.tasks.count
  end
end
