# frozen_string_literal: true

require 'test_helper'

class ProjectWebhooksFlowTest < ::ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as(create(:user))
    @project = create(:project, user: @user)
  end

  test 'create webhook' do
    post project_webhooks_path(@project), params: { webhook: { secret: '' } }
    assert_redirected_to project_webhooks_path(@project)
    assert_equal 1, @project.webhooks.count
    assert_nil @project.webhooks.first.secret
  end

  test 'create webhook with secret' do
    post project_webhooks_path(@project), params: { webhook: { secret: '123456' } }
    assert_redirected_to project_webhooks_path(@project)
    assert_equal 1, @project.webhooks.count
    assert_equal '123456', @project.webhooks.first.secret
  end

  test 'delete webhook' do
    wh = @project.webhooks.create
    assert_equal 1, @project.webhooks.count
    delete project_webhook_path(@project, wh)
    assert_redirected_to project_webhooks_path(@project)
    assert_equal 0, @project.webhooks.count
  end
end
