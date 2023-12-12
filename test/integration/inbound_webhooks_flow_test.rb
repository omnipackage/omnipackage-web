# frozen_string_literal: true

require 'test_helper'

class InboundWebhooksFlowTest < ::ActionDispatch::IntegrationTest
  test 'trigger' do
    webhook = create(:webhook, project: create(:project_with_sources))
    assert_difference('webhook.project.tasks.count') do
      post trigger_webhook_path(webhook.key)
      assert_response :success
    end
  end

  test 'with github signature' do
    webhook = create(:webhook, project: create(:project_with_sources), secret: "It's a Secret to Everybody")
    assert_equal 0, webhook.project.tasks.count

    assert_difference('webhook.project.tasks.count') do
      post trigger_webhook_path(webhook.key), headers: { 'X-Hub-Signature-256' => 'sha256=66a0c074deaa0f489ead6537e0d32f9a344b90bbeda705b6ed45ecd3b413fb40' }
      assert_response :success
    end

    assert_no_difference('webhook.project.tasks.count') do
      post trigger_webhook_path(webhook.key), headers: { 'X-Hub-Signature-256' => 'sha256=nope' }
      assert_response :unauthorized
    end

    assert_no_difference('webhook.project.tasks.count') do
      post trigger_webhook_path(webhook.key)
      assert_response :unauthorized
    end
  end
end
