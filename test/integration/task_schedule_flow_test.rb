require 'test_helper'

class TaskScheduleFlowTest < ::ActionDispatch::IntegrationTest
  include ::ActiveJob::TestHelper

  self.use_transactional_tests = false

  setup do
    @user = sign_in_as(create(:user))
    @project = create(:project_with_sources, user: @user)
    @project.verified!
    @agent = create(:agent)
    ::AgentApi::ApiController.include(::ActiveStorage::SetCurrent)
  end

  teardown do
    @project.destroy!
    @user.destroy!
    @agent.destroy!
  end

  test 'schedule and dequeue task' do
    perform_enqueued_jobs do
      post tasks_path(project_id: @project.id, skip_fetch: 'true')
    end

    assert_equal 1, @project.tasks.count
    task = @project.tasks.first

    assert_redirected_to tasks_path(project_id: @project.id, highlight: task.id)
    assert_predicate task, :pending_build?

    post agent_api_path, headers: { 'Authorization' => "Bearer #{@agent.apikey}" }, params: { payload: { state: 'idle' } }

    assert_response :success
    task.reload

    assert_predicate task, :running?

    post agent_api_path, headers: { 'Authorization' => "Bearer #{@agent.apikey}" }, params: { payload: { state: 'busy', task: { id: task.id }, livelog: 'The quick brown fox jumps over the lazy dog\n' } }

    assert_response :success
    task.reload

    assert_predicate task, :running?

    post agent_api_path, headers: { 'Authorization' => "Bearer #{@agent.apikey}" }, params: { payload: { state: 'finished', task: { id: task.id }, livelog: 'The quick brown fox jumps over the lazy dog', stats: { total_time: 123, lockwait_time: 3 } } }

    assert_response :success
    task.reload

    assert_predicate task, :failed?
    assert_equal 'The quick brown fox jumps over the lazy dog\nThe quick brown fox jumps over the lazy dog', task.log.text
  end
end
