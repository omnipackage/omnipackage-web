require 'test_helper'

class TaskTest < ::ActiveSupport::TestCase
  test 'factory and validation' do
    o = create(:task)

    assert_predicate o, :valid?
    assert_predicate o.sources, :present?
    assert_equal 'pending_fetch', o.state

    assert_predicate build(:task, sources: nil, state: 'pending_build'), :invalid?
    assert_predicate build(:task, sources: nil, state: 'pending_fetch'), :valid?
    assert_predicate build(:task, distro_ids: ['ololo']), :invalid?
    assert_predicate build(:task, distro_ids: []), :invalid?
    assert_predicate build(:task, distro_ids: nil), :invalid?
  end

  test 'create' do
    project = create(:project_with_sources)
    ::Task::Starter.new(project).call

    assert_equal 1, project.tasks.count
  end
end
