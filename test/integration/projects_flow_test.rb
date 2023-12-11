# frozen_string_literal: true

require 'test_helper'

class ProjectsFlowTest < ::ActionDispatch::IntegrationTest
  include ::ActiveJob::TestHelper

  setup do
    @user = sign_in_as(create(:user))
  end

  test 'list projects' do
    get projects_path

    assert_response :success
  end

  test 'show project' do
    project = create(:project, user: @user)
    get project_path(project)

    assert_response :success
  end

  test 'create project' do
    post projects_path, params: { project: { name: 'TestProject', sources_location: 'git@someurl.com/test', sources_kind: 'git' } }

    assert_redirected_to projects_path
    assert_equal 1, @user.projects.count
    assert_enqueued_with job: ::SourcesFetchJob, args: [@user.projects.first.id]
  end

  test 'not create invalid project' do
    post projects_path, params: { project: { name: 'TestProject', sources_location: 'git@someurl.com/test', sources_kind: 'git', sources_subdir: '../../../etc/passwd' } }

    assert_response :unprocessable_entity
    assert_equal 0, @user.projects.count
  end

  test 'delete project' do
    project = create(:project, user: @user)
    delete project_path(project)
    assert_redirected_to projects_path
    assert_equal 0, @user.projects.count
  end

  test 'create project with real sources' do
    perform_enqueued_jobs do
      post projects_path, params: { project: { name: 'TestProject', sources_location: ::Rails.root.join('test/fixtures/sample_project'), sources_kind: 'localfs' } }

      assert_redirected_to projects_path
      assert_equal 7, @user.projects.sole.repositories.count
    end
  end
end
