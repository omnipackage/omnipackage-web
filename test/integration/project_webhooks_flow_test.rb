# frozen_string_literal: true

require 'test_helper'

class ProjectWebhooksFlowTest < ::ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as(create(:user))
    @project = create(:project, user: @user)
  end

  test 'create webhook' do
    assert_difference('@project.webhooks.count') do
      post project_webhooks_path(@project), params: { webhook: { secret: '' } }
      assert_redirected_to project_webhooks_path(@project)
    end
    assert_nil @project.webhooks.first.secret
  end

  test 'create webhook with secret' do
    assert_difference('@project.webhooks.count') do
      post project_webhooks_path(@project), params: { webhook: { secret: '123456' } }
      assert_redirected_to project_webhooks_path(@project)
    end
    assert_equal '123456', @project.webhooks.first.secret
  end

  test 'delete webhook' do
    wh = @project.webhooks.create
    assert_difference('@project.webhooks.count', -1) do
      delete project_webhook_path(@project, wh)
      assert_redirected_to project_webhooks_path(@project)
    end
  end
end
