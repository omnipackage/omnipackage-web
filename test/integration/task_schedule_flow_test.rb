# frozen_string_literal: true

require 'test_helper'

class TaskScheduleFlowTest < ::ActionDispatch::IntegrationTest
  self.use_transactional_tests = false

  setup do
    @user = sign_in_as(create(:user))
    @project = create(:project_with_sources, user: @user)
    @agent = create(:agent)
  end

  teardown do
    ::Project::SourcesTarball.where(project_id: @project.id).destroy_all # TODO fix creation of multiple tarballs
    @project.destroy!
    @user.destroy!
    @agent.destroy!
  end

  test 'schedule and dequeue task' do
    post project_tasks_path(@project)
    assert_equal 1, @project.tasks.count
    task = @project.tasks.first
    assert_redirected_to project_tasks_path(@project, highlight: task.id)
    assert task.scheduled?

    post agent_api_path, headers: { 'Authorization' => "Bearer: #{@agent.apikey}" }, params: { payload: { state: 'idle' } }
    assert_response :success
    task.reload
    assert task.running?

    post agent_api_path, headers: { 'Authorization' => "Bearer: #{@agent.apikey}" }, params: { payload: { state: 'finished', task: { id: task.id }, livelog: 'The quick brown fox jumps over the lazy dog' } }
    assert_response :success
    task.reload
    assert task.finished?
    assert_equal 'The quick brown fox jumps over the lazy dog', task.log.text
  end
end
